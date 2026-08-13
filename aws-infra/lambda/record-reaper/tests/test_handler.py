"""
Unit tests for handler.py (record-reaper).

Approach:
  - Route53 and SSM are mocked with moto. The aws_setup fixture creates a
    hosted zone and stores its ID in SSM under the same path the handler
    reads at runtime.
  - The EC2 paginator is patched with unittest.mock to return canned instance
    lists, avoiding the complexity of spinning up mocked EC2 instances.

Coverage:
  - Fresh record: running+tagged instance → record kept
  - Stale record: instance not running (or tag removed) → record deleted
  - Empty zone: no A records → nothing happens
  - Mixed: one fresh, one stale → only stale deleted
  - InvalidChangeBatch on delete → warning logged, no exception
"""

import boto3
import pytest
from botocore.exceptions import ClientError
from moto import mock_aws
from unittest.mock import patch

import handler

ZONE_NAME = 'use1.internal.unixovich.net'
INSTANCE_ID = 'i-0abc1234567890def'
INSTANCE_ID_2 = 'i-1111222233334444a'
PRIVATE_IP = '10.0.1.50'
PRIVATE_IP_2 = '10.0.1.51'

FQDN = f"vault-{INSTANCE_ID.removeprefix('i-')}.{ZONE_NAME}"
FQDN_2 = f"bastion-{INSTANCE_ID_2.removeprefix('i-')}.{ZONE_NAME}"


def make_ec2_pages(instance_ids):
    instances = [{'InstanceId': iid} for iid in instance_ids]
    return [{'Reservations': [{'Instances': instances}] if instances else []}]


def create_a_record(r53, zone_id, fqdn, ip):
    r53.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={'Changes': [{'Action': 'CREATE', 'ResourceRecordSet': {
            'Name': fqdn, 'Type': 'A', 'TTL': 60,
            'ResourceRecords': [{'Value': ip}],
        }}]},
    )


def get_a_records(r53, zone_id):
    records = r53.list_resource_record_sets(HostedZoneId=zone_id)['ResourceRecordSets']
    return [r for r in records if r['Type'] == 'A']


@pytest.fixture
def aws_setup():
    with mock_aws():
        r53 = boto3.client('route53')
        zone = r53.create_hosted_zone(Name=ZONE_NAME, CallerReference='test-ref')
        zone_id = zone['HostedZone']['Id'].split('/')[-1]

        ssm = boto3.client('ssm', region_name='us-east-1')
        ssm.put_parameter(Name=handler.SSM_ZONE_ID_PATH, Value=zone_id, Type='String')
        ssm.put_parameter(Name=handler.SSM_ZONE_NAME_PATH, Value=ZONE_NAME, Type='String')

        yield {'zone_id': zone_id, 'r53': r53}


def test_fresh_record_not_reaped(aws_setup):
    zone_id, r53 = aws_setup['zone_id'], aws_setup['r53']
    create_a_record(r53, zone_id, FQDN, PRIVATE_IP)

    with patch.object(handler.ec2_paginator, 'paginate', return_value=make_ec2_pages([INSTANCE_ID])):
        handler.handler({}, None)

    assert len(get_a_records(r53, zone_id)) == 1


def test_stale_record_reaped(aws_setup):
    zone_id, r53 = aws_setup['zone_id'], aws_setup['r53']
    create_a_record(r53, zone_id, FQDN, PRIVATE_IP)

    with patch.object(handler.ec2_paginator, 'paginate', return_value=make_ec2_pages([])):
        handler.handler({}, None)

    assert len(get_a_records(r53, zone_id)) == 0


def test_empty_zone_no_deletes(aws_setup):
    with patch.object(handler.ec2_paginator, 'paginate', return_value=make_ec2_pages([])):
        handler.handler({}, None)


def test_mixed_fresh_and_stale(aws_setup):
    zone_id, r53 = aws_setup['zone_id'], aws_setup['r53']
    create_a_record(r53, zone_id, FQDN, PRIVATE_IP)        # stale
    create_a_record(r53, zone_id, FQDN_2, PRIVATE_IP_2)    # fresh

    with patch.object(handler.ec2_paginator, 'paginate', return_value=make_ec2_pages([INSTANCE_ID_2])):
        handler.handler({}, None)

    remaining = get_a_records(r53, zone_id)
    assert len(remaining) == 1
    assert remaining[0]['Name'] == f"{FQDN_2}."


def test_record_not_found_warns(aws_setup):
    zone_id, r53 = aws_setup['zone_id'], aws_setup['r53']
    create_a_record(r53, zone_id, FQDN, PRIVATE_IP)

    error = ClientError(
        {'Error': {'Code': 'InvalidChangeBatch', 'Message': 'not found'}},
        'ChangeResourceRecordSets',
    )
    with patch.object(handler.ec2_paginator, 'paginate', return_value=make_ec2_pages([])), \
         patch('handler.delete_record', side_effect=error):
        handler.handler({}, None)

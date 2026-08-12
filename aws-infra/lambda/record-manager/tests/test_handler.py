"""
Unit tests for handler.py.

Approach:
  - Route53 and SSM are mocked with moto. The aws_setup fixture creates a
    hosted zone, captures its moto-generated ID, and stores it in SSM under
    the same path the handler reads at runtime. This lets get_zone() resolve
    correctly and allows Route53 assertions to verify real mocked state.
  - EC2 calls (get_instance) are patched with unittest.mock to avoid the
    complexity of creating mocked EC2 instances in moto.
  - Module-level boto3 clients in handler.py are created before mock_aws()
    starts, but moto intercepts at the botocore transport layer so all calls
    within the mock context are captured.

Coverage:
  - All four skip conditions (no instance, no manage-r53-record tag, no Name tag,
    no private IP)
  - Happy path for state=running (A record upserted)
  - Happy path for state=shutting-down (A record deleted)
  - Edge case: record not found on shutdown → warning logged, no exception
"""

import boto3
import pytest
from botocore.exceptions import ClientError
from moto import mock_aws
from unittest.mock import patch

import handler

ZONE_NAME = 'use1.internal.unixovich.net'
INSTANCE_ID = 'i-0abc1234567890def'
SHORT_ID = INSTANCE_ID.removeprefix('i-')
PRIVATE_IP = '10.0.1.50'


def make_event(state, instance_id=INSTANCE_ID):
    return {'detail': {'instance-id': instance_id, 'state': state}}


def make_instance(tags=None, private_ip=PRIVATE_IP):
    """Returns a minimal instance dict that passes all handler guards by
    default."""
    return {
        'InstanceId': INSTANCE_ID,
        'PrivateIpAddress': private_ip,
        'Tags': tags if tags is not None else [
            {'Key': 'Name', 'Value': 'vault'},
            {'Key': 'manage-r53-record', 'Value': ''},
        ],
    }


@pytest.fixture
def aws_setup():
    """
    Spins up moto-mocked Route53 and SSM.
    Stores the moto-generated zone ID in SSM so the handler resolves it
    correctly.
    """
    with mock_aws():
        r53 = boto3.client('route53')
        zone = r53.create_hosted_zone(
            Name=ZONE_NAME, CallerReference='test-ref'
        )
        zone_id = zone['HostedZone']['Id'].split('/')[-1]

        ssm = boto3.client('ssm', region_name='us-east-1')
        ssm.put_parameter(
            Name=handler.SSM_ZONE_ID_PATH, Value=zone_id, Type='String'
        )
        ssm.put_parameter(
            Name=handler.SSM_ZONE_NAME_PATH, Value=ZONE_NAME, Type='String'
        )

        yield {'zone_id': zone_id}


# --- skip conditions ---

def test_instance_not_found_skips(aws_setup):
    with patch('handler.get_instance', return_value=None), \
         patch('handler.upsert_record') as mock_upsert:
        handler.handler(make_event('running'), None)
        mock_upsert.assert_not_called()


def test_no_manage_r53_tag_skips(aws_setup):
    instance = make_instance(tags=[{'Key': 'Name', 'Value': 'vault'}])
    with patch('handler.get_instance', return_value=instance), \
         patch('handler.upsert_record') as mock_upsert:
        handler.handler(make_event('running'), None)
        mock_upsert.assert_not_called()


def test_no_name_tag_skips(aws_setup):
    instance = make_instance(tags=[{'Key': 'manage-r53-record', 'Value': ''}])
    with patch('handler.get_instance', return_value=instance), \
         patch('handler.upsert_record') as mock_upsert:
        handler.handler(make_event('running'), None)
        mock_upsert.assert_not_called()


def test_no_private_ip_skips(aws_setup):
    instance = make_instance(private_ip=None)
    with patch('handler.get_instance', return_value=instance), \
         patch('handler.upsert_record') as mock_upsert:
        handler.handler(make_event('running'), None)
        mock_upsert.assert_not_called()


# --- running state ---

def test_running_creates_record(aws_setup):
    zone_id = aws_setup['zone_id']
    instance = make_instance()

    with patch('handler.get_instance', return_value=instance):
        handler.handler(make_event('running'), None)

    fqdn = f"vault-{SHORT_ID}.{ZONE_NAME}"

    r53 = boto3.client('route53')
    records = r53.list_resource_record_sets(
        HostedZoneId=zone_id
    )['ResourceRecordSets']
    a_records = [r for r in records if r['Type'] == 'A']
    assert len(a_records) == 1
    assert a_records[0]['Name'] == f"{fqdn}."
    assert a_records[0]['ResourceRecords'][0]['Value'] == PRIVATE_IP


# --- shutting-down state ---

def test_shutting_down_deletes_record(aws_setup):
    zone_id = aws_setup['zone_id']
    fqdn = f"vault-{SHORT_ID}.{ZONE_NAME}"
    instance = make_instance()

    # Pre-create the record so the handler has something to delete.
    r53 = boto3.client('route53')
    r53.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={'Changes': [{'Action': 'CREATE', 'ResourceRecordSet': {
            'Name': fqdn, 'Type': 'A', 'TTL': 60,
            'ResourceRecords': [{'Value': PRIVATE_IP}],
        }}]},
    )

    with patch('handler.get_instance', return_value=instance):
        handler.handler(make_event('shutting-down'), None)

    records = r53.list_resource_record_sets(
        HostedZoneId=zone_id
    )['ResourceRecordSets']
    a_records = [r for r in records if r['Type'] == 'A']
    assert len(a_records) == 0


def test_shutting_down_record_not_found_warns(aws_setup):
    # Lambda fires on shutting-down but no A record exists (e.g. Lambda never
    # ran on start) — should log a warning and not raise.
    instance = make_instance()
    error = ClientError(
        {'Error': {'Code': 'InvalidChangeBatch', 'Message': 'not found'}},
        'ChangeResourceRecordSets',
    )
    with patch('handler.get_instance', return_value=instance), \
         patch('handler.delete_record', side_effect=error):
        handler.handler(make_event('shutting-down'), None)

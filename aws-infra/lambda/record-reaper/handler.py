"""
DNS Record Reaper
=================
Safety net for record-manager: periodically deletes stale Route53 private-zone
A records whose owning EC2 instance is no longer running with the
manage-r53-record tag.

record-manager is event-driven and can miss deletions (Lambda error, instance
terminated directly via API, manage-r53-record tag removed post-creation).
This Lambda runs on a schedule and converges the zone toward the correct state:
only running, opted-in instances have A records.

Logic:
  1. Collect all running EC2 instances that have the manage-r53-record tag.
  2. List all A records in the private hosted zone.
  3. For each A record, reconstruct the instance ID from the record name.
  4. If the instance is not in the running+opted-in set, delete the record.

Trigger:
  EventBridge scheduled rule — runs periodically (e.g. hourly).

Zone discovery:
  The Lambda reads the hosted zone ID and zone name from SSM Parameter Store at
  runtime using AWS_REGION (auto-injected by AWS). The SSM paths below store
  region-specific values, so the same code resolves the correct private zone in
  each region without any Terraform-injected environment variables.

Prerequisites:
  - SSM parameters must exist in the same region (published by 02-networking/core-dns)
"""

import boto3
import logging
import os
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Auto-injected by AWS into every Lambda execution environment.
REGION = os.environ['AWS_REGION']

# Published by aws-infra/02-networking/core-dns in both regions.
# Each region stores its own zone ID and name under the same path.
SSM_ZONE_ID_PATH = '/tf/aws-infra/networking/core-dns/private-zone-id'
SSM_ZONE_NAME_PATH = '/tf/aws-infra/networking/core-dns/private-zone-name'

ec2 = boto3.client('ec2', region_name=REGION)
ec2_paginator = ec2.get_paginator('describe_instances')
route53 = boto3.client('route53')
route53_paginator = route53.get_paginator('list_resource_record_sets')
ssm = boto3.client('ssm', region_name=REGION)


def get_zone():
    zone_id = ssm.get_parameter(Name=SSM_ZONE_ID_PATH)['Parameter']['Value']
    zone_name = ssm.get_parameter(Name=SSM_ZONE_NAME_PATH)['Parameter']['Value']
    return zone_id, zone_name


def make_instance_id(name, zone_name):
    # Construct instance id from record name
    return 'i-' + name.removesuffix('.' + zone_name + '.').split('-')[-1]


def delete_record(zone_id, record):

    route53.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={
            'Changes': [{
                'Action': 'DELETE',
                'ResourceRecordSet': {
                    'Name': record['Name'],
                    'Type': record['Type'],
                    'TTL': record['TTL'],
                    'ResourceRecords': record['ResourceRecords']
                }
            }]
        }
    )


def handler(event, context):
    # Only running, opted-in instances should have A records. Filtering here
    # means a record is reaped if its instance stopped, was terminated, or had
    # the manage-r53-record tag removed while running.
    instances = set()
    for page in ec2_paginator.paginate(
        Filters=[
            {'Name': 'instance-state-name', 'Values': ['running']},
            {'Name': 'tag-key', 'Values': ['manage-r53-record']},
        ],
        PaginationConfig={'PageSize': 50},
    ):
        for reservation in page['Reservations']:
            for instance in reservation['Instances']:
                instances.add(instance['InstanceId'])
    logger.info(f"Instances: {instances}")

    zone_id, zone_name = get_zone()
    records = []
    for page in route53_paginator.paginate(HostedZoneId=zone_id):
        for r in page['ResourceRecordSets']:
            if r['Type'] == 'A':
                records.append(r)
    logger.info(f"Zone {zone_name} records: {len(records)}")

    for r in records:
        i = make_instance_id(r["Name"], zone_name)
        if i not in instances:
            try:
                delete_record(zone_id, r)
                logger.info(f"Deleted A record for non-existing instance: {i}")
            except ClientError as e:
                if e.response['Error']['Code'] == 'InvalidChangeBatch':
                    logger.warning(f"Failed to delete record - not found")
                else:
                    raise

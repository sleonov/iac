"""
DNS Record Manager Lambda
=========================
Automatically creates and deletes Route53 private-zone A records as EC2 instances
start and stop. Deployed by the Terraform module at:
  aws-infra/05-dns-automation/record-manager/

Trigger:
  EventBridge rule (aws_cloudwatch_event_rule) fires on EC2 state-change notifications
  for states "running" and "shutting-down". The rule and Lambda are deployed in both
  us-east-1 and us-west-1; the same handler code runs in both regions.

Opt-in mechanism:
  Only instances with the tag key "manage-r53-record" are processed. Instances
  without it are silently skipped.

DNS state tag:
  On creation, Lambda writes the resulting FQDN to a separate "fqdn" tag on the
  instance. On deletion, Lambda reads it back to know which record to remove.
  This tag is not declared in Terraform, so Terraform will never overwrite it.

Zone discovery:
  The Lambda reads the hosted zone ID and zone name from SSM Parameter Store at
  runtime using AWS_REGION (auto-injected by AWS). The SSM paths below store
  region-specific values, so the same code resolves the correct private zone in
  each region without any Terraform-injected environment variables.

Prerequisites:
  - Instance must have tag "manage-r53-record" (any value — signals opt-in)
  - Instance must have tag "Name" (used as the DNS label together with the
    instance ID to form a unique FQDN: <Name>-<instance-id-without-i->.zone)
  - SSM parameters must exist in the same region (published by 02-networking/core-dns)
"""

import boto3
import logging
import os

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Auto-injected by AWS into every Lambda execution environment.
REGION = os.environ['AWS_REGION']

# Published by aws-infra/02-networking/core-dns in both regions.
# Each region stores its own zone ID and name under the same path.
SSM_ZONE_ID_PATH = '/tf/aws-infra/networking/core-dns/private-zone-id'
SSM_ZONE_NAME_PATH = '/tf/aws-infra/networking/core-dns/private-zone-name'

TTL = 60

ec2 = boto3.client('ec2', region_name=REGION)
route53 = boto3.client('route53')
ssm = boto3.client('ssm', region_name=REGION)


def get_zone():
    zone_id = ssm.get_parameter(Name=SSM_ZONE_ID_PATH)['Parameter']['Value']
    zone_name = ssm.get_parameter(Name=SSM_ZONE_NAME_PATH)['Parameter']['Value']
    return zone_id, zone_name


def get_instance(instance_id):
    response = ec2.describe_instances(InstanceIds=[instance_id])
    reservations = response.get('Reservations', [])
    if not reservations:
        return None
    return reservations[0]['Instances'][0]


def get_tag(instance, key):
    for tag in instance.get('Tags', []):
        if tag['Key'] == key:
            return tag['Value']
    return None


def has_tag(instance, key):
    return any(tag['Key'] == key for tag in instance.get('Tags', []))


def make_fqdn(name, instance_id, zone_name):
    # Strip the "i-" prefix — purely cosmetic, keeps the label cleaner.
    return f"{name}-{instance_id.removeprefix('i-')}.{zone_name}"


def upsert_record(zone_id, fqdn, ip):
    route53.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={
            'Changes': [{
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'Name': fqdn,
                    'Type': 'A',
                    'TTL': TTL,
                    'ResourceRecords': [{'Value': ip}]
                }
            }]
        }
    )


def delete_record(zone_id, fqdn, ip):
    route53.change_resource_record_sets(
        HostedZoneId=zone_id,
        ChangeBatch={
            'Changes': [{
                'Action': 'DELETE',
                'ResourceRecordSet': {
                    'Name': fqdn,
                    'Type': 'A',
                    'TTL': TTL,
                    'ResourceRecords': [{'Value': ip}]
                }
            }]
        }
    )


def tag_instance(instance_id, fqdn):
    # Write the created FQDN back to the instance so delete can read it later
    # without having to reconstruct the zone name.
    ec2.create_tags(
        Resources=[instance_id],
        Tags=[{'Key': 'fqdn', 'Value': fqdn}]
    )


def handler(event, context):
    instance_id = event['detail']['instance-id']
    state = event['detail']['state']

    logger.info(f"Processing instance {instance_id} state={state} region={REGION}")

    instance = get_instance(instance_id)
    if not instance:
        logger.warning(f"Instance {instance_id} not found, skipping")
        return

    # Skip instances that have not opted in to DNS registration.
    if not has_tag(instance, 'manage-r53-record'):
        logger.info(f"Instance {instance_id} has no manage-r53-record tag, skipping")
        return

    name = get_tag(instance, 'Name')
    if not name:
        logger.warning(f"Instance {instance_id} has no Name tag, skipping")
        return

    private_ip = instance.get('PrivateIpAddress')
    if not private_ip:
        logger.warning(f"Instance {instance_id} has no private IP, skipping")
        return

    zone_id, zone_name = get_zone()

    if state == 'running':
        fqdn = make_fqdn(name, instance_id, zone_name)
        # If the Name tag changed since last start, the old record would be
        # orphaned — delete it before creating the new one.
        old_fqdn = get_tag(instance, 'fqdn')
        if old_fqdn and old_fqdn != fqdn:
            delete_record(zone_id, old_fqdn, private_ip)
            logger.info(f"Deleted stale record {old_fqdn}")
        upsert_record(zone_id, fqdn, private_ip)
        tag_instance(instance_id, fqdn)
        logger.info(f"Created {fqdn} -> {private_ip}")

    elif state == 'shutting-down':
        # Read FQDN from the tag written at creation time — avoids reconstructing
        # the zone name and handles any name changes that may have occurred.
        fqdn = get_tag(instance, 'fqdn')
        if not fqdn:
            logger.warning(f"Instance {instance_id} fqdn tag is empty, skipping delete")
            return
        delete_record(zone_id, fqdn, private_ip)
        logger.info(f"Deleted {fqdn}")

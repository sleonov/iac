#!/bin/bash
# Opens an interactive SSM session to the Vault server or client instance.
# Usage: vault-ssm-session.sh server|client [region]
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: vault-ssm-session.sh server|client [region]" >&2
  exit 1
fi

TARGET=$1
REGION=${2:-us-east-1}

case "$TARGET" in
  server|client) ;;
  *) echo "error: target must be 'server' or 'client'" >&2; exit 1 ;;
esac

INSTANCE_ID=$(aws ssm get-parameter \
  --name "/tf/aws-infra/vault/$TARGET/instance-id" \
  --query Parameter.Value --output text \
  --region "$REGION")

INSTANCE_STATE=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].State.Name' --output text \
  --region "$REGION" 2>/dev/null || echo "not-found")

if [[ "$INSTANCE_STATE" != "running" ]]; then
  echo "error: vault-$TARGET $INSTANCE_ID is not running (state: $INSTANCE_STATE)" >&2
  exit 1
fi

aws ssm start-session --target "$INSTANCE_ID" --region "$REGION"

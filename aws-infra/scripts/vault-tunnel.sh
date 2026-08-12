#!/bin/bash
# Opens an SSM port forwarding tunnel to the Vault instance (instance:8200 → localhost:8200),
# runs the command passed as the second argument, then closes the tunnel.
# Usage: vault-tunnel.sh <region> <command>
set -euo pipefail

REGION=$1
CMD=$2

INSTANCE_ID=$(aws ssm get-parameter \
  --name /tf/aws-infra/vault/server/instance-id \
  --query Parameter.Value --output text \
  --region "$REGION")

INSTANCE_STATE=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].State.Name' --output text \
  --region "$REGION" 2>/dev/null || echo "not-found")

if [[ "$INSTANCE_STATE" != "running" ]]; then
  echo "error: vault server $INSTANCE_ID is not running (state: $INSTANCE_STATE)" >&2
  exit 1
fi

aws ssm start-session \
  --target "$INSTANCE_ID" \
  --document-name AWS-StartPortForwardingSession \
  --parameters portNumber=8200,localPortNumber=8200 \
  --region "$REGION" &
TUNNEL_PID=$!

until curl -s http://127.0.0.1:8200/v1/sys/health > /dev/null 2>&1; do sleep 1; done

eval "$CMD"
EXIT_CODE=$?

kill $TUNNEL_PID 2>/dev/null || true
exit $EXIT_CODE

#!/bin/bash
# Runs shell commands on an EC2 instance via SSM send-command and prints the output.
# Polls until the command completes before fetching output.
# Usage: ssm-run.sh <region> <ssm-param-path-for-instance-id> <command1> [command2] ...
set -euo pipefail

REGION=$1
PARAM_PATH=$2
shift 2
COMMANDS=("$@")

INSTANCE_ID=$(aws ssm get-parameter \
  --name "$PARAM_PATH" \
  --query Parameter.Value --output text \
  --region "$REGION")

INSTANCE_STATE=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].State.Name' --output text \
  --region "$REGION" 2>/dev/null || echo "not-found")

if [[ "$INSTANCE_STATE" != "running" ]]; then
  echo "error: instance $INSTANCE_ID is not running (state: $INSTANCE_STATE)" >&2
  exit 1
fi

COMMANDS_JSON=$(printf '%s\n' "${COMMANDS[@]}" | jq -R . | jq -sc '{"commands": .}')

CMD_ID=$(aws ssm send-command \
  --instance-id "$INSTANCE_ID" \
  --document-name AWS-RunShellScript \
  --parameters "$COMMANDS_JSON" \
  --region "$REGION" \
  --query "Command.CommandId" \
  --output text)

until aws ssm get-command-invocation \
  --command-id "$CMD_ID" \
  --instance-id "$INSTANCE_ID" \
  --region "$REGION" \
  --query "Status" --output text 2>/dev/null | grep -qE "^(Success|Failed)$"; do sleep 1; done

aws ssm get-command-invocation \
  --command-id "$CMD_ID" \
  --instance-id "$INSTANCE_ID" \
  --region "$REGION" \
  --query "StandardOutputContent" \
  --output text

# EventBridge resources use the aws_cloudwatch_event_* naming — EventBridge was originally
# called CloudWatch Events and the Terraform resource names were never updated after the rebrand.
# These resources are visible in the AWS console under EventBridge > Rules.

# Rule: fires on EC2 instance state changes.
# stopped covers persistent spot interruption (stop behavior) — spot instances
# transition running→stopping→stopped, never through shutting-down.
resource "aws_cloudwatch_event_rule" "ec2_state_west" {
  provider    = aws.west
  name        = "dns-record-manager-ec2-state"
  description = "Trigger DNS record manager Lambda on EC2 instance start, shutdown, and stop"

  event_pattern = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["running", "shutting-down", "stopped"]
    }
  })
}

# Target: points the rule at the Lambda function in this region.
resource "aws_cloudwatch_event_target" "lambda_west" {
  provider  = aws.west
  rule      = aws_cloudwatch_event_rule.ec2_state_west.name
  target_id = "dns-record-manager"
  arn       = aws_lambda_function.record_manager_west.arn
}

# Lambda permission: grants EventBridge the right to INVOKE this Lambda (inbound).
# This is separate from the Lambda's IAM execution role, which controls what the Lambda
# can DO when it runs (outbound). Without this, EventBridge gets permission denied
# even though the Lambda has a valid execution role.
resource "aws_lambda_permission" "eventbridge_west" {
  provider      = aws.west
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.record_manager_west.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_west.arn
}

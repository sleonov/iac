# EventBridge resources use the aws_cloudwatch_event_* naming — EventBridge was originally
# called CloudWatch Events and the Terraform resource names were never updated after the rebrand.
# These resources are visible in the AWS console under EventBridge > Rules.

# Rule: fires on EC2 instance state changes (running = instance started, shutting-down = instance stopping).
resource "aws_cloudwatch_event_rule" "ec2_state_east" {
  provider    = aws.east
  name        = "dns-record-manager-ec2-state"
  description = "Trigger DNS record manager Lambda on EC2 instance start and shutdown"

  event_pattern = jsonencode({
    source        = ["aws.ec2"]
    "detail-type" = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["running", "shutting-down"]
    }
  })
}

# Target: points the rule at the Lambda function in this region.
resource "aws_cloudwatch_event_target" "lambda_east" {
  provider  = aws.east
  rule      = aws_cloudwatch_event_rule.ec2_state_east.name
  target_id = "dns-record-manager"
  arn       = aws_lambda_function.record_manager_east.arn
}

# Lambda permission: grants EventBridge the right to INVOKE this Lambda (inbound).
# This is separate from the Lambda's IAM execution role, which controls what the Lambda
# can DO when it runs (outbound). Without this, EventBridge gets permission denied
# even though the Lambda has a valid execution role.
resource "aws_lambda_permission" "eventbridge_east" {
  provider      = aws.east
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.record_manager_east.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_east.arn
}

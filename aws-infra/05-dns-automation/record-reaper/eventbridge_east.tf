# EventBridge resources use the aws_cloudwatch_event_* naming — EventBridge was originally
# called CloudWatch Events and the Terraform resource names were never updated after the rebrand.
# These resources are visible in the AWS console under EventBridge > Rules.

resource "aws_cloudwatch_event_rule" "record_reaper_east" {
  provider            = aws.east
  name                = "dns-record-reaper-schedule"
  description         = "Trigger DNS record reaper Lambda hourly to clean up stale A records"
  schedule_expression = var.schedule_expression
}

resource "aws_cloudwatch_event_target" "record_reaper_east" {
  provider  = aws.east
  rule      = aws_cloudwatch_event_rule.record_reaper_east.name
  target_id = "dns-record-reaper"
  arn       = aws_lambda_function.record_reaper_east.arn
}

# Lambda permission: grants EventBridge the right to INVOKE this Lambda (inbound).
# This is separate from the Lambda's IAM execution role, which controls what the Lambda
# can DO when it runs (outbound). Without this, EventBridge gets permission denied
# even though the Lambda has a valid execution role.
resource "aws_lambda_permission" "eventbridge_east" {
  provider      = aws.east
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.record_reaper_east.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.record_reaper_east.arn
}

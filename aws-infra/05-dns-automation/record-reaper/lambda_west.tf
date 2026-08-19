resource "aws_cloudwatch_log_group" "record_reaper_west" {
  provider          = aws.west
  name              = "/aws/lambda/dns-record-reaper"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "record_reaper_west" {
  provider         = aws.west
  function_name    = "dns-record-reaper"
  description      = "Periodically deletes stale Route53 A records for terminated/stopped EC2 instances"
  role             = aws_iam_role.record_reaper.arn
  runtime          = "python3.12"
  handler          = "handler.handler"
  filename         = data.archive_file.record_reaper.output_path
  source_code_hash = data.archive_file.record_reaper.output_base64sha256
  timeout          = 60
  depends_on       = [aws_cloudwatch_log_group.record_reaper_west]
}

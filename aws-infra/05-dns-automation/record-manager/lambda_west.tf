resource "aws_cloudwatch_log_group" "record_manager_west" {
  provider          = aws.west
  name              = "/aws/lambda/dns-record-manager"
  retention_in_days = var.log_retention_days
}

resource "aws_lambda_function" "record_manager_west" {
  provider         = aws.west
  function_name    = "dns-record-manager"
  description      = "Creates/deletes Route53 A records on EC2 instance start/shutdown"
  role             = aws_iam_role.record_manager.arn
  runtime          = "python3.12"
  handler          = "handler.handler"
  filename         = data.archive_file.record_manager.output_path
  source_code_hash = data.archive_file.record_manager.output_base64sha256
  timeout          = 30
  depends_on       = [aws_cloudwatch_log_group.record_manager_west]
}

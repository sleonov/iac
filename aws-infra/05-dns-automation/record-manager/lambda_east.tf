resource "aws_lambda_function" "record_manager_east" {
  provider         = aws.east
  function_name    = "dns-record-manager"
  description      = "Creates/deletes Route53 A records on EC2 instance start/shutdown"
  role             = aws_iam_role.record_manager.arn
  runtime          = "python3.12"
  handler          = "handler.handler"
  filename         = data.archive_file.record_manager.output_path
  source_code_hash = data.archive_file.record_manager.output_base64sha256
  # Default timeout (3s) is too tight for SSM + EC2 describe + Route53 calls.
  timeout = 30
}

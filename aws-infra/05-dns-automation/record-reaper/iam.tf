# IAM role for the DNS record reaper Lambda (shared across both regions — IAM is global).
#
# Permissions:
#   AWSLambdaBasicExecutionRole — CloudWatch Logs (write Lambda logs)
#   AmazonRoute53FullAccess     — delete stale A records in private hosted zones
#   AmazonEC2ReadOnlyAccess     — describe instances to build the running+opted-in set
#   AmazonSSMReadOnlyAccess     — read private zone ID and name from SSM at runtime; the Lambda
#                                 uses AWS_REGION (injected automatically by AWS) to query SSM in
#                                 its own region, so the same code resolves the correct zone in
#                                 both us-east-1 and us-west-1 without any Terraform-injected config

resource "aws_iam_role" "record_reaper" {
  provider = aws.east
  name     = "dns-record-reaper"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "logs" {
  provider   = aws.east
  role       = aws_iam_role.record_reaper.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "route53" {
  provider   = aws.east
  role       = aws_iam_role.record_reaper.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

resource "aws_iam_role_policy_attachment" "ec2_read" {
  provider   = aws.east
  role       = aws_iam_role.record_reaper.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_read" {
  provider   = aws.east
  role       = aws_iam_role.record_reaper.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

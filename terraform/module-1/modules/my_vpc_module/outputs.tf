output "subnet_id" {
  value = aws_subnet.subnet.id
}

output "ami_id" {
  value = data.aws_ssm_parameter.amazon_ami_id.value
}
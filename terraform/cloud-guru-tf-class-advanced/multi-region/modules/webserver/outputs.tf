output "vpc_id" {
  description = "Vpc id"
  value = module.vpc.vpc_id
}

output "instance_id" {
  description = "Instance id"
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
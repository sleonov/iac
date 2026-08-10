output "bastion_instance_profile_name" {
  value = aws_iam_instance_profile.bastion.name
}

output "bastion_instance_profile_arn" {
  value = aws_iam_instance_profile.bastion.arn
}

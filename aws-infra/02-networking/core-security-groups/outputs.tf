output "bastion_east_sg_id" {
  value = aws_security_group.bastion_east.id
}

output "bastion_west_sg_id" {
  value = aws_security_group.bastion_west.id
}

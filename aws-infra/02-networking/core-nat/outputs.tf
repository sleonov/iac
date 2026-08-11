output "nat_east_instance_id" {
  value = aws_instance.nat_east.id
}

output "nat_west_instance_id" {
  value = aws_instance.nat_west.id
}

output "nat_east_eni_id" {
  value = aws_instance.nat_east.primary_network_interface_id
}

output "nat_west_eni_id" {
  value = aws_instance.nat_west.primary_network_interface_id
}

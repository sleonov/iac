output "east_igw_id" {
  value = aws_internet_gateway.east.id
}

output "west_igw_id" {
  value = aws_internet_gateway.west.id
}

output "east_public_route_table_id" {
  value = aws_route_table.east_public.id
}

output "east_private_route_table_id" {
  value = aws_route_table.east_private.id
}

output "west_public_route_table_id" {
  value = aws_route_table.west_public.id
}

output "west_private_route_table_id" {
  value = aws_route_table.west_private.id
}

output "east_db_route_table_id" {
  value = aws_route_table.east_db.id
}

output "west_db_route_table_id" {
  value = aws_route_table.west_db.id
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.east_to_west.id
}

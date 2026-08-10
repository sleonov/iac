output "east_vpc_id" {
  value = aws_vpc.east.id
}

output "west_vpc_id" {
  value = aws_vpc.west.id
}

output "east_vpc_cidr" {
  value = aws_vpc.east.cidr_block
}

output "west_vpc_cidr" {
  value = aws_vpc.west.cidr_block
}
output "mysql-endpoint" {
  description = "Connection end-point"
  value = aws_db_instance.default.address
}
output "lambda_east_arn" {
  value       = aws_lambda_function.record_manager_east.arn
}

output "lambda_west_arn" {
  value       = aws_lambda_function.record_manager_west.arn
}

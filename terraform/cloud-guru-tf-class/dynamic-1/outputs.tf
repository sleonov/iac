output "WebServerURL" {
  description = "Web Server URL"
  value       = join("", ["http://", aws_instance.my-instance.public_ip])
}

output ExecutionDateTime {
  description = "Date/Time of Execution"
  value       = timestamp()
}

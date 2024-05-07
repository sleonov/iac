output "instance_ids" {
  description = "Instance ids"
  value       = toset([for i in aws_instance.instances : i.id])
}
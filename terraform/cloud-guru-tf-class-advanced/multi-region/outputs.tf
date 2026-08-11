output "VirginiaServerIP" {
  description = "IP address of server in Virginia"
  value = module.web_server_virginia.public_ip
}

output "OregonServerIP" {
  description = "IP address of server in Oregon"
  value = module.web_server_oregon.public_ip
}
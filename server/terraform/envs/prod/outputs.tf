output "management_instance_public_ip" {
  value = module.app.management_instance_public_ip
}

output "app_instance_private_ip" {
  value = module.app.app_instance_private_ip
}

output "db_instance_endpoint" {
  value = module.app.db_instance_endpoint
}

output "namespace" {
  value = var.namespace
}
output "auth_service_name" {
  value = module.auth_deploy.name
}
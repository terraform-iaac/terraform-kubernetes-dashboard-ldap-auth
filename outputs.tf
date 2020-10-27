output "namespace" {
  value = var.namespace
}
output "auth_service" {
  value = module.auth_deploy.name
}
# Auth service deployment
module "auth_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.7"

  name          = "dashboard-ldap-auth"
  namespace     = var.namespace
  image         = "admindod/k8s_ldap_auth:v1.0.9"
  internal_port = var.service_ports
  custom_labels = {
    app = "dashboard-ldap-auth"
  }
  env        = local.auth_env
  env_secret = local.auth_env_secret
}
module "auth_service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"

  app_name      = module.auth_deploy.name
  app_namespace = var.namespace
  port_mapping  = var.service_ports
  type          = "NodePort"
  custom_labels = {
    app = "${module.auth_deploy.name}"
  }
}

# Deployment of service for recreate new tokens for service account users
module "recreate_token_deploy" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_deploy.git?ref=v1.0.7"

  name                  = "tokens-for-dashboard"
  namespace             = var.namespace
  image                 = "admindod/genarate-tokens:v1.0.8"
  service_account_name  = kubernetes_service_account.admin_service_account[0].metadata[0].name
  service_account_token = true
  tty                   = true
  custom_labels = {
    app = "tokens-for-dashboard"
  }
  env = local.tokens_env
}
module "recreate_token_service" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_service.git?ref=v1.0.0"

  app_name      = module.recreate_token_deploy.name
  app_namespace = var.namespace
  type          = "NodePort"
  port_mapping  = var.service_ports
  custom_labels = {
    app     = "${module.recreate_token_deploy.name}"
    primary = "true"
  }
}

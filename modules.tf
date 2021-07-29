module "auth_service" {
  source  = "terraform-iaac/service/kubernetes"
  version = "1.0.3"

  app_name      = kubernetes_deployment.deploy.metadata[0].labels.app
  app_namespace = var.namespace
  port_mapping  = var.service_ports
}
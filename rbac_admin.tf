# Admin Auth service account
resource "kubernetes_service_account" "admin_service_account" {
  count = var.create_admin_role ? 1 : 0

  metadata {
    name      = var.admin_service_account
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role_binding" "admin_role_binding" {
  count = var.create_admin_role ? 1 : 0

  metadata {
    name = var.admin_service_account
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin_service_account[0].metadata[0].name
    namespace = var.namespace
  }
}

data "kubernetes_secret" "admin_token" {
  count = var.create_admin_role ? 1 : 0

  metadata {
    name      = kubernetes_service_account.admin_service_account[0].default_secret_name
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "admin_auth_token" {
  count = var.create_admin_role ? 1 : 0

  metadata {
    name      = "${kubernetes_service_account.admin_service_account[0].metadata[0].name}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.admin_service_account[0].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"

  lifecycle {
    ignore_changes = [data]
  }
}

resource "kubernetes_secret" "custom_admin_auth_token" {
  count = var.create_admin_role ? 0 : 1

  metadata {
    name      = "${var.admin_service_account}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = var.admin_service_account
    }
  }

  type = "kubernetes.io/service-account-token"

  lifecycle {
    ignore_changes = [data]
  }
}
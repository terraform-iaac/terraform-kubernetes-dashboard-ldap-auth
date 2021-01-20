# Read Only Auth service account
resource "kubernetes_service_account" "read_only_service_account" {
  count = var.create_read_only_role ? 1 : 0

  metadata {
    name      = var.read_only_service_account
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "read_only_cluster_role" {
  count = var.create_read_only_role ? 1 : 0

  metadata {
    name = "${var.read_only_service_account}-cluster-role"
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "daemonsets", "statefulsets"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes", "pods", "pods/log", "namespaces"]
    verbs      = ["list", "watch"]
  }

  dynamic "rule" {
    for_each = var.additional_readonly_rule
    content {
      api_groups = rule.value.api_groups
      resources  = rule.value.resources
      verbs      = rule.value.verbs
    }
  }
}

resource "kubernetes_cluster_role_binding" "read_only_role_binding" {
  count = var.create_read_only_role ? 1 : 0

  metadata {
    name = var.read_only_service_account
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.read_only_cluster_role[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.read_only_service_account[0].metadata[0].name
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "read_only_auth_token" {
  count = var.create_read_only_role ? 1 : 0

  metadata {
    name      = "${var.read_only_service_account}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.read_only_service_account[0].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"

  lifecycle {
    ignore_changes = [data]
  }
}

resource "kubernetes_secret" "custom_read_only_auth_token" {
  count = var.create_read_only_role ? 0 : 1

  metadata {
    name      = "${var.read_only_service_account}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = var.read_only_service_account
    }
  }

  type = "kubernetes.io/service-account-token"

  lifecycle {
    ignore_changes = [data]
  }
}
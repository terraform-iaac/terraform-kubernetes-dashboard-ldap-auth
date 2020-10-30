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
}


# User Auth service account
resource "kubernetes_service_account" "user_service_account" {
  count = var.create_user_role ? 1 : 0

  metadata {
    name      = var.user_service_account
    namespace = var.namespace
  }
}
resource "kubernetes_cluster_role" "user_cluster_role" {
  count = var.create_user_role ? 1 : 0

  metadata {
    name = "${var.user_service_account}-cluster-role"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "pods/log", "deployments", "jobs", "services", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods/exec"]
    verbs      = ["create"]
  }
  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list"]
  }
}
resource "kubernetes_cluster_role_binding" "user_role_binding" {
  count = var.create_user_role ? 1 : 0

  metadata {
    name = var.user_service_account
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.user_cluster_role[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.user_service_account[0].metadata[0].name
    namespace = var.namespace
  }
}
resource "kubernetes_secret" "user_auth_token" {
  count = var.create_user_role ? 1 : 0

  metadata {
    name      = "${var.user_service_account}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.user_service_account[0].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}


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
    api_groups = [""]
    resources  = ["nodes", "pods", "pods/log", "namespaces"]
    verbs      = ["list", "watch"]
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log"]
    verbs      = ["get"]
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
}

# Secret storage for bind users passwords
resource "kubernetes_secret" "pswd_secrets" {
  metadata {
    name      = "password-secrets"
    namespace = var.namespace
  }

  data = {
    LDAP_BIND_PASSWORD = var.ldap_reader_password
  }

  type = "Opaque"
}

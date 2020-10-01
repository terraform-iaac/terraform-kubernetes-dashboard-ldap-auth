# Kubernetes Dashboard
resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace ? 1 : 0

  metadata {
    annotations = {
      name      = var.namespace
    }
    name        = var.namespace
  }
}

#Dashboard
resource "helm_release" "dashboard" {
  name            = local.dashboard_chart
  repository      = local.dashboard_repository
  chart           = local.dashboard_chart
  namespace       = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  cleanup_on_fail = true
  version         = var.chart_version

  set {
    name  = "ingress.enabled"
    value = "true"
  }

  set {
    name  = "ingress.hosts[0]"
    value = "${var.dashboard_subdomain}${var.domain}"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = "${var.dashboard_subdomain}${var.domain}"
  }
  set {
    name  = "ingress.tls[0].secretName"
    value = var.tls
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/whitelist-source-range"
    value = replace(var.cidr_whitelist, ",", "\\,")
    type  = "string"
  }
  set {
    name  = "metricsScraper.enabled"
    value = "true"
  }
  set {
    name  = "rbac.clusterReadOnlyRole"
    value = var.readonly_user
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-cache-duration"
    value = "200 201 202 10m"
    type  = "string"
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-response-headers"
    value = "Authorization"
    type  = "string"
  }
  set {
    name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-url"
    value = "http://${module.auth_deploy.name}.${var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace}.svc.cluster.local/"
    type  = "string"
  }

  dynamic "set" {
    for_each  = var.enable_skip_button ? [{}] : []
    content {
      name  = "extraArgs[0]"
      value = "--enable-skip-login"
    }
  }

  dynamic "set" {
    for_each = var.additional_set
    content {
      name   = set.value.name
      value  = set.value.value
      type   = lookup(set.value, "type", null )
    }
  }
}

# Admin Token
resource "kubernetes_service_account" "admin_service_account" {
  count = var.create_admin_token ? 1 : 0

  metadata {
    name      = local.dashboard_admin_service_account
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  automount_service_account_token = true
}
resource "kubernetes_cluster_role_binding" "admin_role_binding" {
  count = var.create_admin_token ? 1 : 0

  metadata {
    name = local.dashboard_admin_service_account
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin_service_account[0].metadata[0].name
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
}
data "kubernetes_secret" "admin_token" {
  count = var.create_admin_token ? 1 : 0

  metadata {
    name      = kubernetes_service_account.admin_service_account[0].default_secret_name
    namespace = kubernetes_namespace.namespace[0].id
  }
}


//---------------------------------------------------LDAP-AUTH--------------------------------------------------------//
# Admin Auth Token
resource "kubernetes_secret" "admin_auth_token" {
  count = var.create_admin_token ? 1 : 0

  metadata {
    name = "${kubernetes_service_account.admin_service_account[0].metadata[0].name}-auth-token"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.admin_service_account[0].metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

# User Auth Token
resource "kubernetes_service_account" "user_service_account" {
  count = var.create_user_token ? 1 : 0

  metadata {
    name      = var.user_service_account
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  automount_service_account_token = false
}
resource "kubernetes_cluster_role" "user_cluster_role" {
  count = var.create_user_token ? 1 : 0

  metadata {
    name = "${var.user_service_account}-cluster-role"
  }
  rule {
    api_groups = [""]
    resources  = ["namespaces", "pods", "nodes", "pods/log", "deployments", "jobs", "services"]
    verbs      = ["get", "list", "watch"]
  }
}
resource "kubernetes_cluster_role_binding" "user_role_binding" {
  count = var.create_user_token ? 1 : 0

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
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
}
resource "kubernetes_secret" "user_auth_token" {
  metadata {
    name = "${var.user_service_account}-auth-token"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.user_service_account.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}


# Read Only Auth Token
resource "kubernetes_service_account" "read_only_service_account" {
  count = var.create_read_only_token ? 1 : 0

  metadata {
    name      = var.read_only_account
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
  automount_service_account_token = false
}
resource "kubernetes_cluster_role" "read_only_cluster_role" {
  count = var.create_read_only_token ? 1 : 0

  metadata {
    name = "${var.read_only_account}-cluster-role"
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "namespaces"]
    verbs      = ["list", "watch"]
  }
}
resource "kubernetes_cluster_role_binding" "read_only_role_binding" {
  count = var.create_read_only_token ? 1 : 0

  metadata {
    name = var.read_only_account
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.read_only_cluster_role[0].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.read_only_service_account[0].metadata[0].name
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
}
resource "kubernetes_secret" "read_only_auth_token" {
  metadata {
    name = "${var.read_only_account}-auth-token"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.read_only_service_account.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
}

# Secret for bind users passwords
resource "kubernetes_secret" "pswd_secrets" {
  metadata {
    name = "password-secrets"
    namespace = var.namespace
  }

  data = {
    LDAP_BIND_PASSWORD = var.ldap_reader_password
  }

  type = "Opaque"
}

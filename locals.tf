locals {
  labels = {
    "app" = "${var.prefix_name}kubernetes-dashboard-ldap-auth"
  }

  tokens_env = [
    {
      name  = "ADMIN_TOKEN_NAME"
      value = var.create_admin_role ? kubernetes_secret.admin_auth_token[0].metadata[0].name : "${var.admin_service_account}-token"
    },
    {
      name  = "USER_TOKEN_NAME"
      value = var.create_user_role ? kubernetes_secret.user_auth_token[0].metadata[0].name : "${var.user_service_account}-token"
    },
    {
      name  = "READ_ONLY_TOKEN_NAME"
      value = var.create_read_only_role ? kubernetes_secret.read_only_auth_token[0].metadata[0].name : "${var.read_only_service_account}-token"
    },
    {
      name  = "ADMIN_SERVICE_ACCOUNT_NAME"
      value = var.create_admin_role ? kubernetes_service_account.admin_service_account[0].metadata[0].name : var.admin_service_account
    },
    {
      name  = "USER_SERVICE_ACCOUNT_NAME"
      value = var.create_user_role ? kubernetes_service_account.user_service_account[0].metadata[0].name : var.user_service_account
    },
    {
      name  = "READ_ONLY_SERVICE_ACCOUNT_NAME"
      value = var.create_read_only_role ? kubernetes_service_account.read_only_service_account[0].metadata[0].name : var.read_only_service_account
    },
    {
      name  = "NAMESPACE"
      value = var.namespace
    }
  ]
  auth_env = [
    {
      name  = "ADMIN_GROUP"
      value = var.ldap_admin_group
    },
    {
      name  = "USER_GROUP"
      value = var.ldap_user_group
    },
    {
      name  = "READ_ONLY_GROUP"
      value = var.ldap_read_only_group
    },
    {
      name  = "AUTH_NAME"
      value = "Authenticate for access to K8s dashboard"
    },
    {
      name  = "LDAP_BIND_DN"
      value = "cn=${var.ldap_reader_user},ou=users,${var.ldap_dn_search}"
    },
    {
      name  = "LDAP_REQUIRED_GROUP"
      value = "cn=${var.ldap_login_group},ou=groups,${var.ldap_dn_search}"
    },
    {
      name  = "LDAP_URL"
      value = "ldap://${var.ldap_domain_url}:${var.ldap_port}/${var.ldap_dn_search}?${var.ldap_attributes}?${var.ldap_scope}?${var.ldap_filter}"
    }
  ]
  auth_env_secret = [
    {
      name        = "DASHBOARD_ADMIN_TOKEN"
      secret_name = var.create_admin_role ? kubernetes_secret.admin_auth_token[0].metadata[0].name : kubernetes_secret.custom_admin_auth_token[0].metadata[0].name
      secret_key  = "token"
    },
    {
      name        = "DASHBOARD_USER_TOKEN"
      secret_name = var.create_user_role ? kubernetes_secret.user_auth_token[0].metadata[0].name : kubernetes_secret.custom_user_auth_token[0].metadata[0].name
      secret_key  = "token"
    },
    {
      name        = "DASHBOARD_READ_ONLY_TOKEN"
      secret_name = var.create_read_only_role ? kubernetes_secret.read_only_auth_token[0].metadata[0].name : kubernetes_secret.custom_read_only_auth_token[0].metadata[0].name
      secret_key  = "token"
    },
    {
      name        = "LDAP_BIND_PASSWORD"
      secret_name = kubernetes_secret.pswd_secrets.metadata[0].name
      secret_key  = "LDAP_BIND_PASSWORD"
    }
  ]
}
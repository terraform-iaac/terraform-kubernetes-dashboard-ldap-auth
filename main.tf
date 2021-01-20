# Secret storage for bind users passwords
resource "kubernetes_secret" "pswd_secrets" {
  metadata {
    name      = "${var.prefix_name}password-secrets"
    namespace = var.namespace
  }

  data = {
    LDAP_BIND_PASSWORD = var.ldap_reader_password
  }

  type = "Opaque"
}

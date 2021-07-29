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

# Auth + Recreate token Deployment
resource "kubernetes_deployment" "deploy" {
  metadata {
    name      = local.labels.app
    namespace = var.namespace
    labels    = local.labels
  }
  spec {
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        labels = local.labels
      }
      spec {
        service_account_name            = var.create_admin_role ? kubernetes_service_account.admin_service_account[0].metadata[0].name : var.cluster_admin_role
        automount_service_account_token = true

        container {
          name  = "ldap-auth"
          image = var.auth_docker_image

          port {
            name           = "auth"
            container_port = var.service_ports.0.internal_port
            protocol       = "TCP"
          }

          dynamic "env" {
            for_each = local.auth_env
            content {
              name  = env.value.name
              value = env.value.value
            }
          }
          dynamic "env" {
            for_each = local.auth_env_secret
            content {
              name = env.value.name
              value_from {
                secret_key_ref {
                  name = env.value.secret_name
                  key  = env.value.secret_key
                }
              }
            }
          }

          resources {
            requests = {
              memory = "10Mi"
            }
          }

          tty = true
        }

        container {
          name  = "recreate-tokens"
          image = var.recreate_token_docker_image

          dynamic "env" {
            for_each = local.tokens_env
            content {
              name  = env.value.name
              value = env.value.value
            }
          }

          resources {
            requests = {
              memory = "6Mi"
            }
          }

          tty = true
        }
      }
    }
  }
}
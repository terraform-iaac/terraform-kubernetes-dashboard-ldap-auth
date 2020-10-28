# Modules for create kubernetes dashboard with LDAP authentication  

## For enable ldap in dashboard you must have kubernetes-dashboard module with specific ingress annotations:
 ```shell script
module "kubernetes_dashboard" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_dashboard.git?ref=v1.1.3"

  domain         = "example.com"
  tls            = "secret-tls"
  additional_set = [
    {
      name       = "ingress.annotations.kubernetes\\.io/ingress\\.class"
      value      = var.internal_nginx_class
      type       = "string"
    },
    // For ldap auth
    {
      name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-url"
      value = "http://${your_auth_service_name_in_kubernetes}.${kubernetes_dashboard_namespace}.svc.cluster.local/"
      type  = "string"
    },
    {
      name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-cache-duration"
      value = "200 201 202 10m"
      type  = "string"
    },
    {
      name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-response-headers"
      value = "Authorization"
      type  = "string"
    }
  ]
}
 ```


Source: https://kubernetes.github.io/dashboard/

#### For LDAP authentication in dashboard you need config LDAP Active Directory with at least one admin users group (default 'dashboard-admin').

####Folder 'docker' consist Apache LDAP configuration and recreation token script.
module "kubernetes_dashboard" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_dashboard.git?ref=v1.1.3"

  domain         = "example.com"
  tls            = "secret-tls"
  additional_set = [
    {
      name       = "ingress.annotations.kubernetes\\.io/ingress\\.class"
      value      = "nginx-internal"
      type       = "string"
    },
    // For ldap auth
    {
      name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-url"
      value = "http://${module.kubernetes_auth_dashboard.name}.${module.kubernetes_auth_dashboard.namespace}.svc.cluster.local/"
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

module "kubernetes_auth_dashboard" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_dashboard_ldap_auth.git?ref=v1.0.0"

  # LDAP parameters
  ldap_reader_password = "lam"  // reader bind pass
  ldap_domain_name = "local.example.com"
  ldap_dn_search = "ou=developers,dc=local,dc=example,dc=com" // ou - it`s group where users search (remove it if you want search users in whole LDAP server)
  ldap_attributes = "sAMAccountName,memberOf" // check which group member of auth user
  ldap_scope = "sub" // can be base, one or sub
  ldap_filter = "(objectClass=*)"
}
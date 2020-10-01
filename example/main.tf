module "kubernetes_auth_dashboard" {
  source = "git::https://github.com/greg-solutions/terraform_k8s_dashboard_ldap_auth.git?ref=v1.0.0"

  domain = "example.com"
  tls = "secret-tls"
  cidr_whitelist = "0.0.0.0/0, 1.1.1.1/1"

  namespace = "kuberntes-auth-dashboard"

  # Service account names for base roles
  user_service_account = "kubernetes-dashboard-user"
  read_only_account = "kubernetes-dashboard-read-only"

  # LDAP parameters
  ldap_reader_password = "lam"  // reader bind pass
  ldap_domain_name = "local.example.com"
  ldap_dn_search = "ou=developers,dc=local,dc=example,dc=com" // ou - it`s group where users search (remove it if you want search users in whole LDAP server)
  ldap_attributes = "sAMAccountName,memberOf" // check which group member of auth user
  ldap_scope = "sub" // can be base, one or sub
  ldap_filter = "(objectClass=*)"
}
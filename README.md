# Kubernetes dashboard with LDAP authentication
Terraform module for creation kubernetes dashboard with LDAP authentication.  

## Workflow

Module for add LDAP authentication to exist kubernetes-dashboard. Previously you need to create login group inside your LDAP server, which must consist at least one user group (default: admin, user and read-only).
You can choose whatever group you want/won't to add to LDAP auth.

## Software Requirements

Name | Description
--- | --- |
Terraform | >= v0.14.9
Kubernetes provider | >= 2.0.1
Docker | <= 20.10.5

## Usage
### Terraform
For LDAP authentication in dashboard you need config LDAP Active Directory with required group 'dashboard-login' and at least one users group (default 'dashboard-admin').
We recommend use our kubernetes-dashboard module with specific ingress annotations:
 ```shell script
module "kubernetes_dashboard" {
  source = "git::https://github.com/terraform-iaac/terraform-kubernetes-dashboard.git?ref=v1.1.10"
  ...
  additional_set = [
    ...
    // For ldap auth
    {
      name  = "ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/auth-url"
      value = "http://${module.kubernetes_auth_dashboard.auth_service_name}.${module.kubernetes_auth_dashboard.namespace}.svc.cluster.local/"
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
  source = "git::https://github.com/terraform-iaac/terraform-kubernetes-dashboard-ldap-auth.git"

  namespace = module.kubernetes_dashboard.namespace

  # LDAP group names
  ldap_login_group     = "k8s_dashboard_login"
  ldap_admin_group     = "k8s_dashboard_admin"
  ldap_user_group      = "k8s_dashboard_users"
  ldap_read_only_group = "k8s_dashboard_readonly"

  # LDAP parameters
  ldap_reader_password = "SECUREPASS" // reader bind pass
  ldap_domain_url      = "local.example.com"
  ldap_dn_search       = "ou=developers,dc=local,dc=example,dc=com" // ou - it`s group where users search (remove it if you want search users in whole LDAP server)
  ldap_attributes      = "sAMAccountName,memberOf"                  // check which group member of auth user
  ldap_scope           = "sub"                                      // can be base, one or sub
  ldap_filter          = "(objectClass=*)"

  additional_readonly_rule = [
    {
      api_groups = ["extensions"]
      resources  = ["ingresses"]
      verbs      = ["list", "watch"]
    },
    {
      api_groups = ["batch"]
      resources  = ["jobs", "cronjobs"]
      verbs      = ["list", "watch"]
    }
  ]
}
 ```
### Docker
Folder 'docker' consist Apache LDAP configuration and recreation token script. You can create your own images or modify configs as you want.

## Inputs

Name | Description | Type | Default | Example | Required
--- | --- | --- | --- |--- |--- 
prefix_name | Prefix for deployments, services & secrets | `string` | `""` | `my-project-name` | no
namespace | Kubernetes Dashboard namespace | `string` | n/a | `kubernetes-dashboard` | yes 
create_admin_role | Create admin service account & token for auth | `bool` | `true` | n/a | no
create_user_role | Create user service account & token for auth | `bool` | `true` | n/a | no
create_read_only_role | Create read only service account & token for auth | `bool` | `true` | n/a | no
additional_user_rule | Additional rules for user cluster role | <pre>list(object({<br>    api_groups  = string<br>    resources = string<br>    verbs  = string // Optional<br>  }))</pre> | `[]` | <pre>[{<br>  api_groups  = ["extensions"]<br>  resources   = ["ingresses"]<br>  verbs       = ["list", "watch"]<br>}]</pre> | no
additional_readonly_rule | Additional rules for read only cluster role | <pre>list(object({<br>    api_groups  = string<br>    resources = string<br>    verbs  = string // Optional<br>  }))</pre> | `[]` | <pre>[{<br>  api_groups  = ["extensions"]<br>  resources   = ["ingresses"]<br>  verbs       = ["list", "watch"]<br>}]</pre> | no
cluster_admin_role | If create_admin_role false, add admin service account by yourself. Need for recreate tokens. | `string` | `null` | n/a | no
admin_service_account | Admin Service Account (full access) | `string` | `kubernetes-dashboard-admin-ldap-auth` | n/a | no
user_service_account | User Service Account (access to special resources) | `string` | `kubernetes-dashboard-user-ldap-auth` | n/a | no
read_only_service_account | Read Only Service Account (low level access only for read) | `string` | `kubernetes-dashboard-read-only-ldap-auth` | n/a | no
auth_docker_image | Docker Image for auth service | `string` | `iaac/kubernetes-dashboard-ldap-auth-service:latest` | `local-image-as:v1.0` | no
recreate_token_docker_image | Docker Image for recreate token service | `string` | `iaac/kubernetes-dashboard-ldap-auth-recreate-tokens:latest` | `local-image-rt:v1.0` | no
service_ports | Ports for auth request from ingress to service additional_readonly_rule | <pre>list(object({<br>    name  = string<br>    internal_port = string<br>    external_port  = string // Optional<br>  }))</pre> | <pre>[{<br>  name          = "auth"<br>  internal_port = "80"<br>  external_port = "80"<br>}]</pre> | n/a | no

### LDAP config
Name | Description | Type | Default | Example | Required
--- | --- | --- | --- |--- |--- 
ldap_reader_user | Bind username which need for access to read info about users in LDAP server | `string` | `reader` | n/a | no
ldap_reader_password | Bind user password which need for access to read info about users in LDAP server | `string` | n/a | `SUPERSECRERPASS` | yes
ldap_domain_url | Host domain name where ldap deployed | `string` | n/a | `local.example.com` | yes
ldap_port | Port number of the LDAP server | `string` | `389` | n/a | no
ldap_dn_search | Distinguished name (DN) of an entry in the directory. This DN identifies the entry that is starting point of the search. If this component is empty, the search starts at the root DN. | `string` | n/a | `ou=developers,dc=local,dc=example,dc=com` | yes
ldap_attributes | The attributes to be returned. To specify more than one attribute, use commas to delimit the attributes (for example, 'cn,mail,telephoneNumber'). If no attributes are specified in the URL, all attributes are returned. | `string` | `sAMAccountName,memberOf` | n/a | no
ldap_scope | The scope of the search, which can be one of these values: base, one or sub | `string` | `sub` | n/a | no
ldap_filter | Used in apache | `string` | `(objectClass=*)` | n/a | no
ldap_login_group | Login group name in LDAP server (must consist admin, users and readonly groups) | `string` | `k8s-dashboard-login` | n/a | no
ldap_admin_group | Admin group name in LDAP server | `string` | `kk8s-dashboard-admin` | n/a | no
ldap_user_group | User group name in LDAP server | `string` | `k8s-dashboard-user` | n/a | no
ldap_read_only_group | Read only group name in LDAP server | `string` | `k8s-dashboard-read-only` | n/a | no

## Outputs
Name | Description
--- | --- 
namespace | Name of namespace where dashboard deployed
auth_service_name | Name of auth service in kubernetes cluster
variable "prefix_name" {
  description = "Prefix for deployments, services & secrets"
  default     = ""
}
variable "namespace" {
  description = "Kubernetes Dashboard namespace"
  type        = string
}

variable "node_selector" {
  description = "(Optional) Specify node selector for pod"
  type        = map(string)
  default     = null
}

# Bool
variable "create_admin_role" {
  description = "Create admin service account & token for auth"
  default     = true
}
variable "create_user_role" {
  description = "Create user service account & token for auth"
  default     = true
}
variable "create_read_only_role" {
  description = "Create read only service account & token for auth"
  default     = true
}

# RBAC
variable "additional_user_rule" {
  description = "Additional rules for user cluster role"
  default     = []
}
variable "additional_readonly_rule" {
  description = "Additional rules for read only cluster role"
  default     = []
}
variable "cluster_admin_role" {
  description = "If create_admin_role false, add admin service account by yourself. Need for recreate tokens."
  type        = string
  default     = null
}

# SA name
variable "admin_service_account" {
  description = "Admin Service Account (full access)"
  default     = "kubernetes-dashboard-admin-ldap-auth"
}
variable "user_service_account" {
  description = "User Service Account (access to special resources)"
  default     = "kubernetes-dashboard-user-ldap-auth"
}
variable "read_only_service_account" {
  description = "Read Only Service Account (low level access only for read)"
  default     = "kubernetes-dashboard-read-only-ldap-auth"
}

# LDAP config
variable "ldap_reader_user" {
  description = "Bind username which need for access to read info about users in LDAP server"
  default     = "reader"
}
variable "ldap_reader_password" {
  description = "Bind user password which need for access to read info about users in LDAP server"
}
variable "ldap_domain_url" {
  description = "Host domain name where ldap deployed"
}
variable "ldap_port" {
  description = "Port number of the LDAP server"
  default     = "389"
}
variable "ldap_dn_search" {
  description = "Distinguished name (DN) of an entry in the directory. This DN identifies the entry that is starting point of the search. If this component is empty, the search starts at the root DN."
}
variable "ldap_attributes" {
  description = "The attributes to be returned. To specify more than one attribute, use commas to delimit the attributes (for example, 'cn,mail,telephoneNumber'). If no attributes are specified in the URL, all attributes are returned."
  type        = string
  default     = "sAMAccountName,memberOf"
}
variable "ldap_scope" {
  description = "The scope of the search, which can be one of these values: base, one or sub"
  type        = string
  default     = "sub"
}
variable "ldap_filter" {
  description = "Used in apache"
  type        = string
  default     = "(objectClass=*)"
}

# LDAP groups name
variable "ldap_login_group" {
  description = "Login group name in LDAP server (must consist admin, users and readonly groups)"
  type        = string
  default     = "k8s-dashboard-login"
}
variable "ldap_admin_group" {
  description = "Admin group name in LDAP server"
  type        = string
  default     = "k8s-dashboard-admin"
}
variable "ldap_user_group" {
  description = "User group name in LDAP server"
  type        = string
  default     = "k8s-dashboard-user"
}
variable "ldap_read_only_group" {
  description = "Read only group name in LDAP server"
  type        = string
  default     = "k8s-dashboard-read-only"
}

# Deployments
variable "recreate_token_docker_image" {
  description = "Docker Image for auth service"
  default     = "iaac/kubernetes-dashboard-ldap-auth-recreate-tokens:latest"
}
variable "auth_docker_image" {
  description = "DockerImage for recreate token service"
  default     = "iaac/kubernetes-dashboard-ldap-auth-service:latest"
}
variable "service_ports" {
  description = "Ports for auth request from ingress to service"
  default = [
    {
      name          = "auth"
      internal_port = "80"
      external_port = "80"
    }
  ]
}
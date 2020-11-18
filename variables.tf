variable "namespace" {
  description = "Namespace name"
  type        = string
  default     = "kubernetes-dashboard"
}

variable "create_admin_role" {
  description = "Create admin token for auth"
  default     = true
}
variable "create_user_role" {
  description = "Create user token for auth"
  default     = true
}
variable "create_read_only_role" {
  description = "Create read only token for auth"
  default     = true
}

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
variable "additional_groups" {
  type        = list(string)
  description = "Add more group of users"
  default     = []
}

# LDAP URL config
variable "ldap_reader_password" {
  description = "Bind user password which need for access to read info about users in LDAP server"
  default     = "lam"
}
variable "ldap_domain_name" {
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
  description = ""
  type        = string
  default     = "(objectClass=*)"
}

# LDAP groups name
variable "admin_group_name" {
  description = "Admin group name in LDAP server"
  type        = string
  default     = "dashboard-admin"
}
variable "user_group_name" {
  description = "User group name in LDAP server"
  type        = string
  default     = "dashboard-user"
}
variable "read_only_group_name" {
  description = "Read only group name in LDAP server"
  type        = string
  default     = "dashboard-read-only"
}

variable "additional_user_rule" {
  description = "Additional rules for user cluster role"
  default     = []
}
variable "additional_readonly_rule" {
  description = "Additional rules for read only cluster role"
  default     = []
}
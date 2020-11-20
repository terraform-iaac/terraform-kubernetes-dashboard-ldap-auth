# LDAP authentication for Kubernetes-Dashboard module 

This module additional to [kubernetes dashboard](https://github.com/greg-solutions/terraform_k8s_dashboard) module and allow access into Kubernetes cluster with LDAP credentials.

## Usage

For enable ldap in dashboard you must have terraform [kubernetes dashboard](https://github.com/greg-solutions/terraform_k8s_dashboard) module with specific ingress annotations:

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


## Requirements

For LDAP authentication in dashboard you need config LDAP Active Directory with required group 'dashboard-login' and at least one users group (default 'dashboard-admin').
Folder 'docker' consist Apache LDAP configuration and recreation token script.

## Compatibility

Module was tested with OpenLDAP server. If you use Microsoft Active Directory, change variables: 
- ldap_attributes
- ldap_filter
- ldap_scope (optional)

## Annotation
Source: https://kubernetes.github.io/dashboard/
# Modules for create kubernetes dashboard with LDAP authenticate  

## For enable monitoring in dashboard you must have metrics from kube:
 ```shell script
resource "helm_release" "metrics_server" {
  name = "metrics-server"
  repository = "stable"
  chart = "metrics-server"
  namespace = "kube-system"
  cleanup_on_fail = true
  version = "2.11.1"
}
 ```


Source: https://kubernetes.github.io/dashboard/

#### For LDAP authentication in dashboard you need config LDAP Active Directory with at least admin users group (default 'dashboard-admin').
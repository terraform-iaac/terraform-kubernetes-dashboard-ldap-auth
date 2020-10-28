#!/bin/bash

TOKEN_NAME=( "${ADMIN_TOKEN_NAME}" "${USER_TOKEN_NAME}" "${READ_ONLY_TOKEN_NAME}" )
SERVICE_ACCOUNT_NAME=("${ADMIN_SERVICE_ACCOUNT_NAME}" "${USER_SERVICE_ACCOUNT_NAME}" "${READ_ONLY_SERVICE_ACCOUNT_NAME}")

len=${#TOKEN_NAME[@]}

for (( i=0; i<$len; i++ ))
do
(kubectl get secret ${TOKEN_NAME[i]} -n ${NAMESPACE}; ec=$?;
if [ $ec -eq 0 ]; then
kubectl delete secret ${TOKEN_NAME[i]} -n ${NAMESPACE}
kubectl apply -n ${NAMESPACE} -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${TOKEN_NAME[i]}
  annotations:
    kubernetes.io/service-account.name: ${SERVICE_ACCOUNT_NAME[i]}
type: kubernetes.io/service-account-token
EOF
else
  exit 0
fi
[ "$ec" -gt 0 ] && exit 1; exit 0)
done

#!/usr/bin/env bash

set -euo pipefail

for i in {1..5}; do
  sleep 5

  CSR_NAME=$(kubectl get csr -o jsonpath='{.items[?(@.spec.username == "system:serviceaccount:'$NAMESPACE':'$SERVICE_ACCOUNT_NAME'")].metadata.name}')

  if [[ ${CSR_NAME} != "" ]]; then
    kubectl certificate approve ${CSR_NAME}

    break
  fi
done

echo "Certificate signing request approved!"

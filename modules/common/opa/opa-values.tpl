opa: null
mgmt:
  replicate:
    cluster:
      - v1/namespaces
  configmapPolicies:
    enabled: true
    namespaces: [${namespace}, kube-federation-scheduling-policy]
rbac:
  create: false
serviceAccount:
  create: false
  name: ${service_account}

admissionControllerFailurePolicy: ${failure_policy}

#namespaceSelector:
#  matchLabels:
#    openpolicyagent.org/policy: rego

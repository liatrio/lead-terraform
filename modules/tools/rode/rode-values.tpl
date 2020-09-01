grafeas:
  certificates:
    name: ${grafeas_cert}

certificates:
  name: ${rode_cert}

rbac:
  serviceAccountAnnotations:
    eks.amazonaws.com/role-arn: ${iam_arn}

localstack:
  enabled: ${localstack_enabled}

resources:
  limits:
    cpu: 50m
    memory: 200Mi
  requests:
    cpu: 10m
    memory: 100Mi

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "toolchain-nginx"
  hostName: ${ingress_hostname}
  tls:
  - hosts:
    - ${ingress_hostname}

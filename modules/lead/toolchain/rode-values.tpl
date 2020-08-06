grafeas:
  certificates:
    name: ${grafeas_cert}

certificates:
  name: ${rode_cert}

rbac:
  serviceAccountAnnotations:
    eks.amazonaws.com/role-arn: ${iam_arn}

localstack:
  enabled: false

resources:
  limits:
    cpu: 1
    memory: 400Mi
  requests:
    cpu: 10m
    memory: 200Mi

ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "toolchain-nginx"
  hostName: ${ingress_hostname}
  tls:
  - hosts:
    - ${ingress_hostname}

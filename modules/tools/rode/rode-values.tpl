ingress:
  enabled: ${ingress_enabled}
  hosts:
    - host: ${ingress_hostname}
      paths:
        - /
  annotations:
    ${indent(4, yamlencode(ingress_annotations)) ~}

auth:
  oidc:
    ${indent(4, yamlencode(oidc_config)) ~}

rode-ui:
  enabled: false


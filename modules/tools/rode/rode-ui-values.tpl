appUrl: "https://${ui_ingress_hostname}"

ingress:
  enabled: ${ingress_enabled}
  hosts:
    - host: ${ingress_hostname}
      paths:
        - /
  annotations:
    ${indent(4, yamlencode(ingress_annotations))}

rode:
  auth:
    oidc:
      ${indent(8, yamlencode(oidc_config))}

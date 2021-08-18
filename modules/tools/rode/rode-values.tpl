##
## Rode config
##

ingress:
  enabled: ${ingress_enabled}
  hosts:
    - host: ${ingress_hostname}
      paths:
        - /
  annotations:
    ${indent(4, yamlencode(ingress_annotations)) }

auth:
  oidc:
    ${indent(4, yamlencode(oidc_config))}

##
## Rode UI config
##
rode-ui:
  appUrl: "https://${ui_ingress_hostname}"

  ingress:
    enabled: ${ingress_enabled}
    hosts:
      - host: ${ui_ingress_hostname}
        paths:
          - /
    annotations:
      ${indent(4, yamlencode(ingress_annotations))}

  rode:
    auth:
      oidc:
        ${indent(8, yamlencode(oidc_config))}

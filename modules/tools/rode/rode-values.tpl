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
  ingress:
    enabled: ${ingress_enabled}
    hosts:
      - host: ${ui_ingress_hostname}
        paths:
          - /
    annotations:
      ${indent(4, yamlencode(ingress_annotations))}
  auth:
    oidc:
      ${indent(6, yamlencode(oidc_config))}

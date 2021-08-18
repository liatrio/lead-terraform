ingress:
  enabled: ${ ingress_enabled }
  hosts:
    - host: ${ ingress_hostname }
      paths:
        - /
  annotations:
    ${indent( 4, yamlencode( ingress_annotations ) ) }

rode-ui:
  ingress:
    enabled: ${ ui_ingress_enabled }
    hosts:
      - host: ${ ui_ingress_hostname }
        paths:
          - /
    annotations:
      ${indent( 4, yamlencode( ui_ingress_annotations ) ) }

ingress:
  enabled: ${ ingress_enabled }
  hosts:
    - name: ${ ingress_hostname }
      path: "/"
  annotations:
    ${indent( 4, yamlencode( ingress_annotations ) ) }

rode-ui:
  ingress:
    enabled: ${ ui_ingress_enabled }
    hosts:
      - name: ${ ui_ingress_hostname }
        path: "/"
    annotations:
      ${indent( 4, yamlencode( ui_ingress_annotations ) ) }

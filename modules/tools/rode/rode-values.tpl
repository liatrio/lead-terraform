ingress:
  http:
    enabled: ${ingress.enabled}
    hosts:
      - host: ${ingress.http.host}
        paths:
          - /
    annotations:
      ${indent(6, yamlencode(ingress.http.annotations)) ~}
  grpc:
    enabled: ${ingress.enabled}
    hosts:
      - host: ${ingress.grpc.host}
        paths:
          - /
    annotations:
      ${indent(6, yamlencode(ingress.grpc.annotations)) ~}

auth:
  oidc:
    ${indent(4, yamlencode(oidc_config)) ~}

rode-ui:
  enabled: false


grafeas-elasticsearch:
  image:
    tag: ${grafeas_image_tag}


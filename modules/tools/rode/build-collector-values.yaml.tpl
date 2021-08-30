rode:
  host: rode.${namespace}.svc.cluster.local:50051
  disableTransportSecurity: true

  auth:
    proxy:
      enabled: ${auth_enabled}

ingress:
  http:
    enabled: ${ingress.enabled}
    hosts:
      - host: ${ingress.http.host}
        paths:
          - /
    annotations:
      ${indent(6, yamlencode(ingress.http.annotations))}
  grpc:
    enabled: ${ingress.enabled}
    hosts:
      - host: ${ingress.grpc.host}
        paths:
          - /
    annotations:
      ${indent(6, yamlencode(ingress.grpc.annotations)) ~}

rode:
  host: rode.${namespace}.svc.cluster.local:50051
  disableTransportSecurity: true

  auth:
    proxy:
      enabled: ${auth_enabled}


%{~ if host != "" }
ingress:
    enabled: true
    annotations:
      ${indent(6, yamlencode(ingress_annotations))}
    hosts:
      - host: ${host}
        paths:
          - /
%{~ endif }

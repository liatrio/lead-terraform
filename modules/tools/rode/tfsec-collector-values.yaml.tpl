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
      ${indent(4, yamlencode(ingress_annotations)) ~}
    hosts:
      - name: ${host}
        paths:
          - /
%{~ endif }

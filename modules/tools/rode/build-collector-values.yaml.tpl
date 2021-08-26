rode:
  host: rode.${namespace}.svc.cluster.local:50051
  disableTransportSecurity: true

  auth:
    proxy:
      enabled: ${auth_enabled}

%{~ if host != "" }
ingress:
  enabled: true
  hosts:
    - host: ${host}
      paths:
        - /
  annotations:
    ${indent(4, yamlencode(ingress_annotations))}
%{~ endif }

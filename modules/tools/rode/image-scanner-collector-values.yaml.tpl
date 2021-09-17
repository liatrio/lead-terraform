rode:
  host: rode.${namespace}.svc.cluster.local:50051
  disableTransportSecurity: true

  auth:
    proxy:
      enabled: ${auth_enabled}

%{~ if docker_config_secret != "" }
dockerConfigSecret: ${docker_config_secret}
%{~ endif }

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

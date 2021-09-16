rode:
  host: rode.${namespace}.svc.cluster.local:50051
  disableTransportSecurity: true

  auth:
    proxy:
      enabled: ${auth_enabled}

%{~ if length(image_pull_secrets) != 0 }
imagePullSecrets:
%{ for secret in image_pull_secrets ~}
  - name: ${ secret }
%{ endfor ~}
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

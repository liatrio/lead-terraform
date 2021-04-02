protocol: http
elasticsearchHosts: "https://elasticsearch-master:9200"

extraEnvs:
  - name: 'ELASTICSEARCH_USERNAME'
    valueFrom:
      secretKeyRef:
        name: ${elasticsearch_credentials_secret_name}
        key: username
  - name: 'ELASTICSEARCH_PASSWORD'
    valueFrom:
      secretKeyRef:
        name: ${elasticsearch_credentials_secret_name}
        key: password

kibanaConfig:
  kibana.yml: |
    elasticsearch.ssl:
      certificateAuthorities: /usr/share/kibana/config/certs/ca.crt
      verificationMode: certificate

secretMounts:
  - name: ${elasticsearch_certificates_secret_name}
    secretName: ${elasticsearch_certificates_secret_name}
    path: /usr/share/kibana/config/certs

ingress:
  enabled: ${enable_ingress}
  annotations:
    kubernetes.io/ingress.class: toolchain-nginx
  hosts:
    - ${kibana_hostname}
  tls:
    - hosts:
        - ${kibana_hostname}

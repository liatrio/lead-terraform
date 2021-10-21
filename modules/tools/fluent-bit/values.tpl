tolerations:
  - key: EssentialOnly
    operator: Exists
    effect: NoSchedule
backend:
  type: es
  es:
    host: elasticsearch-master
    port: 9200
    type: _doc
    http_user: ${elasticsearch_username}
    http_passwd_secret: ${elasticsearch_credentials_secret_name}
    http_passwd_secret_key: password
    tls: "on"
    tls_verify: "off"
    tls_debug: 1
parsers:
  enabled: true
  json:
    - name: json
filter:
  mergeLogKey: details
resources:
  limits:
    cpu: 300m
    memory: 100Mi
  requests:
    cpu: 100m
    memory: 50Mi

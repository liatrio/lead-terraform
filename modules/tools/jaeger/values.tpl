collector:
  service:
    zipkin:
      port: ${jaeger_zipkin_port}
  autoscaling:
    enabled: true

query:
  service:
    port: 16686

provisionDataStore:
  cassandra: false
  elasticsearch: false
  kafka: false

storage:
  type: elasticsearch
  elasticsearch:
    host: ${elasticsearch_host}
    user: ${elasticsearch_username}
    existingSecret: ${elasticsearch_password_secret_name}
    scheme: https
    indexPrefix: jaeger
    env:
      ES_TLS_SKIP_HOST_VERIFY: true

ingress:
  enabled: true
  annotations:
    "nginx.ingress.kubernetes.io/force-ssl-redirect" : false
    "nginx.ingress.kubernetes.io/proxy-body-size" : "0"
    "kubernetes.io/ingress.class" : "internal-nginx"
  host:
    name: ${litmus_hostname}
    paths:
      frontend: /(.*)
      backend: /backend/(.*)
portal:
  frontend:
    service:
      type: ClusterIP
  server:
    service:
      type: ClusterIP

ingress:
  enabled: true
  annotations:
    ${indent( 4, yamlencode( litmus_ingress_annotations ) ) }
    nginx.ingress.kubernetes.io/rewrite-target: /$1
  host:
    name: ${litmus_hostname}
    paths:
      frontend: /
      backend: /backend/(.*)

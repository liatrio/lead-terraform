ingress:
  enabled: true
  annotations:
    ${indent( 4, yamlencode( litmus_ingress_annotations ) ) }
  host:
    name: ${litmus_hostname}
    paths:
      frontend: /
      backend: /backend/(.*)

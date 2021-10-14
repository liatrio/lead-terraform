dashboard:
  ingress:
    enabled: true
    annotations:
      ${indent( 4, yamlencode( chaos_mesh_ingress_annotations ) ) }
    hosts:
      - name: ${chaos_mesh_hostname}
        paths: ["/"]

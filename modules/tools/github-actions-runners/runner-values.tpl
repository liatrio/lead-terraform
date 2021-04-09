githubOrg: ${github_org}
image: ${image}
labels:
  ${indent( 2, yamlencode( labels ) )}
serviceAccount:
  annotations:
    ${indent( 4, yamlencode( runner_annotations ) ) }
resources:
  requests:
    cpu: 150m
    memory: 256Mi
  limits:
    cpu: 1
    memory: 1Gi
dockerdContainerResources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 500m 
    memory: 512Mi

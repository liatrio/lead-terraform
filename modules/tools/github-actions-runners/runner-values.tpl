githubOrg: ${github_org}
githubRepo: ${github_repo}
image: ${image}
labels:
  ${indent( 2, yamlencode( labels ) )}
serviceAccount:
  annotations:
    ${indent( 4, yamlencode( runner_annotations ) ) }
  name: ${service_account_name}
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
horizontalRunnerAutoscaler:
  minReplicas: ${autoscaler_min_replicas}
  maxReplicas: ${autoscaler_max_replicas}
  scaleAmount: ${autoscaler_scale_amount}
  scaleDuration: ${autoscaler_scale_duration}

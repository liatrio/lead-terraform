auth:
  rootPassword: "${mongodbRootPassword}"
useStatefulSet: true

readinessProbe:
  successThreshold: 2

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 50m
    memory: 200Mi


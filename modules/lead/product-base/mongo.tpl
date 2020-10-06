auth:
  rootPassword: "${mongodbRootPassword}"
useStatefulSet: true

readinessProbe:
  successThreshold: 2

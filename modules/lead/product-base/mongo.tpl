auth:
  rootPassword: "${mongodbRootPassword}"
useStatefulSet: true

livenessProbe:
  successThreshold: 2
readinessProbe:
  successThreshold: 2

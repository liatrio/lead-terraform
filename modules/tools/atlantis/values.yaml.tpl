orgWhitelist: github.com/liatrio/lead-environments

defaultTFVersion: ${default_terraform_version}

service:
  type: ClusterIP

image:
  repository: ghcr.io/liatrio/atlantis-image
  tag: v2.5.0
  pullPolicy: IfNotPresent

resources:
  requests:
    memory: 1Gi
    cpu: 100m
  limits:
    memory: 1Gi
    cpu: 250m

serviceAccount:
  name: atlantis
  annotations:
    "eks.amazonaws.com/role-arn": ${role_arn}

ingress:
  hosts:
    - host: ${ingress_hostname}
      paths: ["/"]
  annotations:
    "kubernetes.io/ingress.class": ${ingress_class}

repoConfig: |
  repos:
    - id: /.*/
      branch: /.*/
      apply_requirements: [approved, mergeable]
      allowed_overrides: [workflow]
      allow_custom_workflows: true

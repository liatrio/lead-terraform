orgWhitelist: github.com/liatrio/lead-environments

defaultTFVersion: ${default_terraform_version}

service:
  type: ClusterIP

image:
  repository: harbor.parker.gg/library/atlantis
  tag: v3
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

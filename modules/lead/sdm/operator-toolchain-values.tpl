cluster: ${cluster}
cluster_domain: ${cluster_domain}
product_version: "${product_version}"
product_stack: ${product_stack}
product_vars: ${product_vars}

product:
  enabled: ${operator_product_enabled}
  image:
    repository: ${image_repository}/operator-product
    tag: ${sdm_version}
  convergeImage:
    repository: ${image_repository}/converge-image
    tag: ${sdm_version}
  terraformSource: ${terraformSource}
  %{ if remote_state_config != "" }
  remoteStateConfig: |
    ${indent(4, remote_state_config)}
  %{ endif }
  defaultProductVariables: ${product_vars}
  defaultProductVersion: "${product_version}"
  defaultJobEnvVariables:
    CLUSTER: ${cluster}
  rbac:
    serviceAccountAnnotations: ${product_service_account_annotations}

aws-event-mapper:
  enabled: ${enable_aws_event_mapper}
  sqsUrl: ${sqs_url}
  rbac:
    serviceAccountAnnotations: ${aws_event_mapper_service_account_annotations}

operators:
  toolchain:
    enabled: ${operator_toolchain_enabled}
    image:
      repository: ${image_repository}/operator-toolchain
  elasticsearch:
    enabled: ${operator_elasticsearch_enabled}
    image:
      repository: ${image_repository}/operator-elasticsearch
  slack:
    enabled: ${operator_slack_enabled}
    image:
      repository: ${image_repository}/operator-slack
    ingress:
      hostName: operator-slack.${namespace}.${cluster_domain}
      annotations:
        kubernetes.io/ingress.class: "toolchain-nginx"
        nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
      tls:
      - hosts:
        - operator-slack.${namespace}.${cluster_domain}
    serviceAccountAnnotations: ${slack_service_account_annotations}
    env:
    - name: workspace_role
      value: ${workspace_role}
    - name: AWS_REGION
      value: ${region}
  jenkins:
    enabled: ${operator_jenkins_enabled}
    image:
      repository: ${image_repository}/operator-jenkins
    serviceAccountAnnotations: ${jenkins_service_account_annotations}

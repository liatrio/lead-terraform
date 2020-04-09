cluster: ${cluster}
cluster_domain: ${cluster_domain}
product_version: "${product_version}"
product:
  enabled: ${operator_product_enabled}
  image:
    repository: ${image_repository}/operator-product
    tag: ${sdm_version}
  convergeImage:
    repository: ${image_repository}/converge-image
    tag: ${sdm_version}
  %{ if remote_state_config != "" }
  remoteStateConfig: |
    ${indent(4, remote_state_config)}
  %{ endif }
  rbac:
    serviceAccountAnnotations: ${product_service_account_annotations}
  types:
    %{ if product_type_aws_enabled }
    - name: product-aws
      terraformSource: github.com/liatrio/lead-terraform//stacks/product-aws
      defaultProductVersion: ${product_version}
      defaultProductVariables:
        builder_images_version: ${builder_images_version}
        cluster_domain: ${cluster_domain}
        codebuild_role: ${codebuild_role}
        codebuild_user: ${codebuild_user}
        codepipeline_role: ${codepipeline_role}
        product_image_repo: ${product_image_repo}
        region: ${region}
        s3_bucket: ${s3_bucket}
      defaultJobEnvVariables:
        CLUSTER: ${cluster}
    %{ endif }
    %{ if product_type_jenkins_enabled }
    - name: product-jenkins
      terraformSource: github.com/liatrio/lead-terraform//stacks/product-jenkins
      defaultProductVersion: ${product_version}
      defaultProductVariables:
        builder_images_version: ${builder_images_version}
        cluster_domain: ${cluster_domain}
        enable_artifactory: "${enable_artifactory}"
        enable_harbor: "${enable_harbor}"
        enable_keycloak: "${enable_keycloak}"
        jenkins_image_version: ${jenkins_image_version}
        product_image_repo: ${product_image_repo}
        region: ${region}
        toolchain_image_repo: ${toolchain_image_repo}
      defaultJobEnvVariables:
        CLUSTER: ${cluster}
    %{ endif }

aws-event-mapper:
  image:
    repository: ${image_repository}/aws-event-mapper
    tag: ${sdm_version}
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
    - name: CLUSTER_DOMAIN
      value: ${cluster_domain}
  jenkins:
    enabled: ${operator_jenkins_enabled}
    image:
      repository: ${image_repository}/operator-jenkins
    serviceAccountAnnotations: ${jenkins_service_account_annotations}

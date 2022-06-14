image:
  repository: ${image_repository}/product-operator
  tag: ${product_operator_version}
  pullSecrets:
    - name: ${image_pull_secret}
converge:
  image:
    repository: ${image_repository}/converge-image
    tag: ${sdm_version}
    pullSecrets:
      - name: ${image_pull_secret}
  additionalPodValues:
    ${indent(4, essential_toleration_values)}
%{ if remote_state_config != "" }
remoteStateConfig: |
  ${indent(2, remote_state_config)}
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
      product_image_repo: ${ecr_image_repo}
      region: ${region}
      toolchain_image_repo: ${toolchain_image_repo}
      cluster: ${cluster}
      aws_environment: ${aws_environment}
      vault_namespace: ${vault_namespace}
      vault_root_token_secret: ${vault_root_token_secret}
      %{ if code_services_enabled }
      codebuild_role: ${codebuild_role}
      codebuild_user: ${codebuild_user}
      codebuild_security_group_id: ${codebuildc_security_group_id}
      codepipeline_role: ${codepipeline_role}
      s3_bucket: ${s3_bucket}
      %{ endif }
    defaultJobEnvVariables:
      CLUSTER: ${cluster}
  %{ endif }

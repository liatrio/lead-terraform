cluster: ${cluster}
cluster_domain: ${cluster_domain}
product_version: "${product_version}"
product_stack: ${product_stack}
product_vars: ${product_vars}

%{ if product_stack == "product-aws" }
product:
  defaultProductVariables:
    codebuild_role: ${codebuild_role}
    codepipeline_role: ${codepipeline_role}
    s3_bucket: ${code_services_s3_bucket}
    codebuild_user: ${codebuild_user}
    cluster_domain: ${cluster_domain}
    region: ${region}
%{ endif }


operators:
  toolchain:
    enabled: ${operator_toolchain_enabled}
  elasticsearch:
    enabled: ${operator_elasticsearch_enabled}
  slack:
    enabled: ${operator_slack_enabled}
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
    serviceAccountAnnotations: ${jenkins_service_account_annotations}
product:
  enabled: ${operator_product_enabled}
aws-event-mapper:
  enabled: ${enable_aws_event_mapper}

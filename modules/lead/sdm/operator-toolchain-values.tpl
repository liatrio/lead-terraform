cluster: ${cluster}
cluster_domain: ${cluster_domain}
product_version: "${product_version}"
product_stack: ${product_stack}
product_vars: ${product_vars}

operators:
  slack:
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
    serviceAccountAnnotations: ${jenkins_service_account_annotations}
  aws-event-mapper:
      enabled: ${enable_aws_event_mapper}

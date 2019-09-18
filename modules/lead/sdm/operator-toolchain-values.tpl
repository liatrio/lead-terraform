cluster: ${cluster}
cluster_domain: ${cluster_domain}
product_version: ${product_version}
product_stack: ${product_stack}
product_vars: ${product_vars}

operators:
  slack:
    ingress:
      hostName: operator-slack.${namespace}.${cluster_domain}
      annotations:
        kubernetes.io/ingress.class: "nginx"
        kubernetes.io/tls-acme: "true"
      tls:
      - hosts:
        - operator-slack.${namespace}.${cluster_domain}
        secretName: operator-slack-ingress-tls
    env:
    - name: workspace_role
      value: ${workspace_role}
    - name: AWS_REGION
      value: ${region}

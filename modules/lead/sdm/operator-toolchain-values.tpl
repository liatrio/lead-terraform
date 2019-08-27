cluster: ${cluster}
cluster_domain: ${cluster_domain}
product_version: ${product_version}

local: ${product_stack == "product-local" ? true : false}

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
  jenkins:
    env:
    - name: CERT_ISSUER_TYPE
      value: ${cert_issuer_type}
    - name: CERT_ISSUER_SERVER
      value: ${cert_issuer_server}
    - name: PRODUCT_STACK
      value: ${product_stack}
    - name: TF_DATA_ROOT
      value: /tf_data/

logstash-url: |
  jenkins:
    globalNodeProperties:
      - envVars:
          env:
          - key: "elasticUrl"
            value: "${logstash_url}"
          - key: "toolchainNamespace"
            value: "${toolchain_namespace}"
          - key: "product"
            value: "${product_name}"
          - key: "stagingNamespace"
            value: "${stagingNamespace}"
          - key: "productionNamespace"
            value: "${productionNamespace}"
          - key: "stagingDomain"
            value: "staging.${appDomain}"
          - key: "productionDomain"
            value: "prod.${appDomain}"
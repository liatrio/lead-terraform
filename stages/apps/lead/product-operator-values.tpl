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
    ${indent(6, essential_toleration_values)}
%{ if remote_state_config != "" }
remoteStateConfig: |
  ${indent(4, remote_state_config)}
%{ endif }

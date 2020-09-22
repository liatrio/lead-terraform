configMaps:
  action_file_yml: |-
    ---
    actions:
      1:
        action: delete_indices
        description: "Clean up ES by deleting old indices"
        options:
          timeout_override:
          continue_if_exception: False
          disable_action: False
          ignore_empty_list: True
        filters:
        - filtertype: age
          source: creation_date
          direction: older
          unit: days
          unit_count: ${days_until_index_expires}
  config_yml: |-
    ---
    client:
      hosts:
        - ${elasticsearch_host}
      port: 9200
      use_ssl: True
      ssl_no_validate: True
cronjob:
  schedule: "0 */6 * * *"
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 75m
    memory: 92Mi

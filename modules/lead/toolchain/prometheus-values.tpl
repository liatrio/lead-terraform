alertmanager:
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['job']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 12h
      receiver: 'slack'
      routes:
      - match:
          alertname: Watchdog
        receiver: 'null'
    # This inhibt rule is a hack from: https://stackoverflow.com/questions/54806336/how-to-silence-prometheus-alertmanager-using-config-files/54814033#54814033
    inhibit_rules:
      - target_match_re:
           alertname: '.+Overcommit'
        source_match:
           alertname: 'Watchdog'
        equal: ['prometheus']
    receivers:
    - name: 'null'
    - name: 'slack'
      slack_configs:
      - api_url: 'https://hooks.slack.com/services/ABCDEF123ABC345ABC345345' # <--- REPLACE THIS WITH YOUR SLACK WEBHOOK
        send_resolved: true
        channel: '#slack-channel-name' # <--- REPLACE THIS WITH YOUR SLACK CHANNEL
        title: '[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] Monitoring Event Notification'
        text: |-
          {{ range .Alerts }}
            *Alert:* {{ .Labels.alertname }} - `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.message }}
            *Prometheus Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}
    # - name: 'slack-channel'
    #   slack_configs:
    #   - api_url: ''
    #     channel: ''
    #     icon_url: https://avatars3.githubusercontent.com/u/3380462
    #     send_resolved: true
    #     title: '{{ template "custom_title" . }}'
    #     text: '{{ template "custom_slack_message" . }}'
    #     templates: |-
    #       {{ define "__single_message_title" }}{{ range .Alerts.Firing }}{{ .Labels.alertname }} @ {{ .Annotations.identifier }}{{ end }}{{ range .Alerts.Resolved }}{{ .Labels.alertname }} @ {{ .Annotations.identifier }}{{ end }}{{ end }}
    #       {{ define "custom_title" }}[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ if or (and (eq (len .Alerts.Firing) 1) (eq (len .Alerts.Resolved) 0)) (and (eq (len .Alerts.Firing) 0) (eq (len .Alerts.Resolved) 1)) }}{{ template "__single_message_title" . }}{{ end }}{{ end }}
    #       {{ define "custom_slack_message" }}
    #       {{ if or (and (eq (len .Alerts.Firing) 1) (eq (len .Alerts.Resolved) 0)) (and (eq (len .Alerts.Firing) 0) (eq (len .Alerts.Resolved) 1)) }}
    #       {{ range .Alerts.Firing }}{{ .Annotations.description }}{{ end }}{{ range .Alerts.Resolved }}{{ .Annotations.description }}{{ end }}
    #       {{ else }}
    #       {{ if gt (len .Alerts.Firing) 0 }}
    #       *Alerts Firing:*
    #       {{ range .Alerts.Firing }}- {{ .Annotations.identifier }}: {{ .Annotations.description }}
    #       {{ end }}{{ end }}
    #       {{ if gt (len .Alerts.Resolved) 0 }}
    #       *Alerts Resolved:*
    #       {{ range .Alerts.Resolved }}- {{ .Annotations.identifier }}: {{ .Annotations.description }}
    #       {{ end }}{{ end }}
    #       {{ end }}
    #       {{ end }}
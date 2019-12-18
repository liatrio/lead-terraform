grafana:
  grafana.ini:
    auth.anonymous:
      enabled: true
      org_name: Main Org.
      org_role: Viewer
  image:
    repository: grafana/grafana
    tag: 6.5.1-ubuntu
    pullPolicy: IfNotPresent

kubeStateMetrics:
  deploymentAnnotations:
    downscaler/exclude: "true"
server:
  deploymentAnnotations:
    downscaler/exclude: "true"
  resources:
    requests:
      cpu: 200m
      memory: 2Gi
    limits:
      cpu: 500m
      memory: 4Gi
nodeExporter:
  #priorityClassName: system-node-critical
  tolerations:
  - key: EssentialOnly
    operator: "Exists"
prometheusOperator:
  resources:
    limits:
      cpu: 200m
      memory: 200Mi
    requests:
      cpu: 100m
      memory: 100Mi
  configReloaderCpu: 100m
  configReloaderMemory: 25Mi
  admissionWebhooks:
    enabled: false
  tlsProxy:
    enabled: false
prometheus:
  prometheusSpec:
    resources:
      requests:
        cpu: 200m
        memory: 2Gi
      limits:
        cpu: 500m
        memory: 4Gi

alertmanager:
  enabled: true
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['namespace', 'pod']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 12h
      routes:
      - match:
          alertname: Watchdog
        receiver: "null"
      - match:
          alertname: KubeControllerManagerDown
        receiver: "null"
      - match:
          alertname: KubeSchedulerDown
        receiver: "null"
      - match:
          alertname: KubeletTooManyPods
        receiver: "null"
      - match:
          namespace: ""
        receiver: slack
      - match:
          namespace: toolchain
        receiver: slack
      - match:
          namespace: lead-system
        receiver: slack
      - match:
          namespace: istio-system
        receiver: slack
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 5Gi
    
    templates:                                                                                                                                                                                                                                                                
    - /etc/alertmanager/config/template*.tmpl 
    receivers:
    - name: 'null'
    - name: 'slack'
      slack_configs:
      - api_url: ${prometheus_slack_webhook_url}
        channel: ${prometheus_slack_channel}
        send_resolved: true
        title: '[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] Monitoring Event Notification'
        text: |-
          {{ range .Alerts }}
            *Alert:* {{ .Labels.alertname }} - `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.message }}
            *Details:*
            {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
            {{ end }}
          {{ end }}
    - name: 'slack-receiver' # Not in use but if we want to configure additional templates we can
      slack_configs:
      - api_url: ${prometheus_slack_webhook_url}
        channel: ${prometheus_slack_channel}
        icon_url: https://avatars3.githubusercontent.com/u/3380462
        send_resolved: true
        title: '{{ template "custom_title" . }}'
        text: '{{ template "custom_slack_message" . }}'
  templateFiles:                                                                                                                                                                                                                                                              
    template_1.tmpl: |-                                                                                                                                                                                                                                                       
      {{ define "__single_message_title" }}{{ range .Alerts.Firing }}{{ .Labels.alertname }} @ {{ .Annotations.identifier }}{{ end }}{{ range .Alerts.Resolved }}{{ .Labels.alertname }} @ {{ .Annotations.identifier }}{{ end }}{{ end }}
      {{ define "custom_title" }}[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] {{ if or (and (eq (len .Alerts.Firing) 1) (eq (len .Alerts.Resolved) 0)) (and (eq (len .Alerts.Firing) 0) (eq (len .Alerts.Resolved) 1)) }}{{ template "__single_message_title" . }}{{ end }}{{ end }}
      {{ define "custom_slack_message" }}
      {{ if or (and (eq (len .Alerts.Firing) 1) (eq (len .Alerts.Resolved) 0)) (and (eq (len .Alerts.Firing) 0) (eq (len .Alerts.Resolved) 1)) }}
      {{ range .Alerts.Firing }}{{ .Annotations.description }}{{ end }}{{ range .Alerts.Resolved }}{{ .Annotations.description }}{{ end }}
      {{ else }}
      {{ if gt (len .Alerts.Firing) 0 }}
      *Alerts Firing:*
      {{ range .Alerts.Firing }}- {{ .Annotations.identifier }}: {{ .Annotations.description }}
      {{ end }}{{ end }}
      {{ if gt (len .Alerts.Resolved) 0 }}
      *Alerts Resolved:*
      {{ range .Alerts.Resolved }}- {{ .Annotations.identifier }}: {{ .Annotations.description }}
      {{ end }}{{ end }}
      {{ end }}
      {{ end }}

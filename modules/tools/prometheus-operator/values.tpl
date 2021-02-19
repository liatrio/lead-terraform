grafana:
  ingress:
    enabled: true
    annotations:
      %{ if ingress_class != "" }
      kubernetes.io/ingress.class: ${ingress_class}
      %{ endif }
      nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    tls:
    - hosts:
      - ${grafana_hostname}
    hosts:
    - ${grafana_hostname}
  grafana.ini:
    auth.anonymous:
      enabled: true
      org_name: Main Org.
      org_role: Viewer
  image:
    repository: grafana/grafana
    tag: 6.5.1-ubuntu
    pullPolicy: IfNotPresent
  service:
    portName: http
  resources:
    limits:
      cpu: 500m
      memory: 256Mi
    requests:
      cpu: 100m
      memory: 128Mi

kube-state-metrics:
  podAnnotations:
    downscaler/exclude: "true"
  resources:
    limits:
      cpu: 200m
      memory: 200Mi
    requests:
      cpu: 10m
      memory: 50Mi
  service:
    annotations:
      prometheus.io/scrape: "false"
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
prometheus-node-exporter:
  service:
    annotations:
      prometheus.io/scrape: "false"
  resources:
    requests:
      cpu: 10m
      memory: 15Mi
    limits:
      cpu: 500m
      memory: 100Mi
prometheusOperator:
  resources:
    limits:
      cpu: 500m
      memory: 300Mi
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
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 95Gi
    resources:
      requests:
        cpu: 500m
        memory: 4Gi
      limits:
        cpu: 2
        memory: 5Gi
    containers:
      - name: prometheus
        env:
        - name: GOGC
          value: "70"

alertmanager:
  enabled: ${enable_alertmanager}
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 1Gi
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['namespace', 'pod']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 1h
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
          alertname: KubeVersionMismatch
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
      - match:
          namespace: elasticsearch
        receiver: slack
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

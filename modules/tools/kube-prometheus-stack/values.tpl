grafana:
  ingress:
    enabled: true
    annotations:
      ${indent( 6, yamlencode( grafana_ingress_annotations ) ) }
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
    tag: 8.1.2-ubuntu
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
  plugins:
    - grafana-timestream-datasource

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
  tolerations:
  - key: EssentialOnly
    operator: "Exists"
prometheusOperator:
  resources:
    limits:
      cpu: 500m
      memory: 800Mi
    requests:
      cpu: 100m
      memory: 100Mi
  configReloaderCpu: 100m
  configReloaderMemory: 25Mi
prometheus:
  annotations:
    downscaler/exclude: "true"
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
  ingress:
    enabled: true
    path: /
    annotations: 
      ${indent( 6, yamlencode( alertmanager_ingress_annotations ) ) }
    hosts:
      - ${alertmanager_hostname}
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 1Gi
    alertmanagerConfigSelector: {}
    alertmanagerConfigNamespaceSelector: {}
  config:
    global:
      resolve_timeout: 5m
    route:
      receiver: 'slack'
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
          alertname: KubeCPUOvercommit
        receiver: "null"
       - match:
          alertname: KubeMemOvercommit
        receiver: "null"
      # Ignoring target down alert because of an issue with aws 
      # issue: https://github.com/aws/containers-roadmap/issues/657
      - match: 
          alertname: TargetDown
        receiver: "null"
    templates:
    - /etc/alertmanager/config/template*.tmpl
    receivers:
    - name: 'null'
    - name: 'slack'
      slack_configs:
      - api_url: ${prometheus_slack_webhook_url}
        channel: ${prometheus_slack_channel}
        color: '{{ range .Alerts }}{{ if eq .Status "firing" }}{{ if eq .Labels.severity "warning" }}#FFAA00{{ else if eq .Labels.severity "critical" }}#FF5100{{ else}}#00C1DB{{ end }}{{ else }}#24AE1D{{ end }}{{ end }}'
        send_resolved: true
        title: '[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{ end }}] Monitoring Event Notification'
        title_link: 'https://${alertmanager_hostname}'
        actions: 
          - type: button
            text: 'Silence :hear_no_evil:'
            url: '{{ template "__alert_silence_link" . }}'
        text: |-
          {{ range .Alerts }}
            {{ if (and (eq .Labels.severity "critical") (ne .Status "resolved")) }} <!here> {{ end }}{{ if eq .Status "firing" }}{{ if eq .Labels.severity "warning" }} :warning: {{ else if eq .Labels.severity "critical" }} :super_dumpster_fire: {{ else }} :information_source: {{ end }}{{ else }} :white_check_mark: {{ end }} *Alert:* {{ .Labels.alertname }} - `{{ .Labels.severity }}`
            *Description:* {{ .Annotations.description }}
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

      {{ define "__alert_silence_link" -}}
      {{ .ExternalURL }}/#/silences/new?filter=%7B
      {{- range .CommonLabels.SortedPairs -}}
          {{- if ne .Name "alertname" -}}
              {{- .Name }}%3D"{{- .Value -}}"%2C%20
          {{- end -}}
      {{- end -}}
      alertname%3D"{{ .CommonLabels.alertname }}"%7D
      {{- end }}


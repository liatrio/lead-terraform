expose:
  type: ingress
  tls:
    enabled: true
    certSource: none # offloaded to the centrally managed nginx ingress controller that's configured with a wildcard cert
  ingress:
    hosts:
      core: ${harbor_ingress_hostname}
    controller: default
    annotations:
      ${indent( 6, yamlencode( ingress_annotations ) ) }

externalURL: https://${harbor_ingress_hostname}

persistence:
  enabled: true
  # Setting it to "keep" to avoid removing PVCs during a helm delete
  # operation. Leaving it empty will delete PVCs after the chart deleted
  resourcePolicy: "keep"
  persistentVolumeClaim:
    registry:
      existingClaim: harbor-registry
      accessMode: ReadWriteOnce
    jobservice:
      storageClass: ${storage_class}
      accessMode: ReadWriteOnce
      size: ${jobservice_pvc_size}
    database:
      existingClaim: harbor-database
      accessMode: ReadWriteOnce

    redis:
      storageClass: ${storage_class}
      accessMode: ReadWriteOnce
      size: ${redis_pvc_size}
  imageChartStorage:
    type: filesystem
    filesystem:
      rootdirectory: /storage

updateStrategy:
  type: Recreate

logLevel: info

portal:
  image:
    repository: goharbor/harbor-portal
    tag: ${img_tag}
  replicas: 1
  resources:
   requests:
     memory: 64Mi
     cpu: 100m
   limits:
     memory: 256Mi
     cpu: 150m
  nodeSelector: {}
  tolerations: []
  affinity: {}
  ## Additional deployment annotations
  podAnnotations: {}

core:
  image:
    repository: goharbor/harbor-core
    tag: ${img_tag}
  replicas: 1
  ## Liveness probe values
  livenessProbe:
    initialDelaySeconds: 300
  resources:
   requests:
     memory: 64Mi
     cpu: 50m
   limits:
     memory: 256Mi
     cpu: 1000m
  nodeSelector: {}
  tolerations: []
  affinity: {}
  ## Additional deployment annotations
  podAnnotations: {}
jobservice:
  image:
    repository: goharbor/harbor-jobservice
    tag: ${img_tag}
  replicas: 1
  maxJobWorkers: 10
  # The logger for jobs: "file", "database" or "stdout"
  jobLogger: stdout
  resources:
    requests:
      memory: 64Mi
      cpu: 10m
    limits:
      memory: 256Mi
      cpu: 50m
  nodeSelector: {}
  tolerations: []
  affinity: {}
  ## Additional deployment annotations
  podAnnotations: {}

registry:
  registry:
    image:
      repository: goharbor/registry-photon
      tag: ${img_tag}
    resources:
      requests:
        memory: 256Mi
        cpu: 100m
      limits:
        memory: 512Mi
        cpu: 1000m
  controller:
    image:
      repository: goharbor/harbor-registryctl
      tag: ${img_tag}

    resources:
      requests:
        memory: 256Mi
        cpu: 100m
      limits:
        memory: 512Mi
        cpu: 250m
  replicas: 1
  nodeSelector: {}
  tolerations: []
  affinity: {}
  ## Additional deployment annotations
  podAnnotations: {}
  # If true, the registry returns relative URLs in Location headers. The client is responsible for resolving the correct URL.
  relativeurls: false
  middleware:
    enabled: false

chartmuseum:
  enabled: false

clair:
  enabled: false

trivy:
  enabled: true
  image:
    repository: goharbor/trivy-adapter-photon
    tag: ${img_tag}
  resources:
    requests:
      memory: 512Mi
      cpu: 200m
    limits:
      memory: 2048Mi
      cpu: 600m
  replicas: 1

notary:
  enabled: false

database:
  # if external database is used, set "type" to "external"
  # and fill the connection informations in "external" section
  type: internal
  internal:
    image:
      repository: goharbor/harbor-db
      tag: ${img_tag}
    initContainerImage:
      repository: busybox
      tag: latest
    resources:
      requests:
        memory: 256Mi
        cpu: 50m
      limits:
        memory: 512Mi
        cpu: 350m
    nodeSelector: {}
    tolerations: []
    affinity: {}
  # The maximum number of connections in the idle connection pool.
  # If it <=0, no idle connections are retained.
  maxIdleConns: 50
  # The maximum number of open connections to the database.
  # If it <= 0, then there is no limit on the number of open connections.
  # Note: the default number of connections is 100 for postgre.
  maxOpenConns: 100
  ## Additional deployment annotations
  podAnnotations: {}

redis:
  # if external Redis is used, set "type" to "external"
  # and fill the connection informations in "external" section
  type: internal
  internal:
    image:
      repository: goharbor/redis-photon
      tag: ${img_tag}
    resources:
      requests:
        memory: 256Mi
        cpu: 100m
    nodeSelector: {}
    tolerations: []
    affinity: {}
  ## Additional deployment annotations
  podAnnotations: {}

metrics:
  enabled: ${metrics_enabled}
  core:
    path: /metrics
    port: 8001
  registry:
    path: /metrics
    port: 8001
  jobservice:
    path: /metrics
    port: 8001
  exporter:
    path: /metrics
    port: 8001

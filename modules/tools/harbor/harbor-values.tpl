expose:
  type: ingress
  tls:
    enabled: true
    certSource: secret
    secret:  
      secretName: harbor-tls
      notarySecretName: notary-tls
  ingress:
    hosts:
      core: ${harbor_ingress_hostname}
      notary: ${notary_ingress_hostname}
    controller: default
    annotations:
      kubernetes.io/ingress.class: "toolchain-nginx"
      nginx.ingress.kubernetes.io/force-ssl-redirect: "${ssl_redirect}"
      nginx.ingress.kubernetes.io/proxy-body-size: "0"

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
    chartmuseum:
      existingClaim: harbor-chartmuseum
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
        cpu: 600m
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
  enabled: true
  # Harbor defaults ChartMuseum to returning relative urls, if you want using absolute url you should enable it by change the following value to 'true'
  absoluteUrl: false
  image:
    repository: goharbor/chartmuseum-photon
    tag: ${img_tag}
  replicas: 1
  resources:
    requests:
      memory: 64Mi
      cpu: 10m
    limits:
      memory: 128Mi
      cpu: 100m
  nodeSelector: {}
  tolerations: []
  affinity: {}
  ## Additional deployment annotations
  podAnnotations: {}

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
  enabled: true
  server:
    image:
      repository: goharbor/notary-server-photon
      tag: ${img_tag}
    replicas: 1
    resources:
      requests:
        memory: 64Mi
        cpu: 10m
      limits:
        memory: 256Mi
        cpu: 250m
  signer:
    image:
      repository: goharbor/notary-signer-photon
      tag: ${img_tag}
    replicas: 1
    resources:
      requests:
        memory: 64Mi
        cpu: 10m
      limits:
        memory: 256Mi
        cpu: 500m
  nodeSelector: {}
  tolerations: []
  affinity: {}
  ## Additional deployment annotations
  podAnnotations: {}
  # Fill the name of a kubernetes secret if you want to use your own
  # TLS certificate authority, certificate and private key for notary
  # communications.
  # The secret must contain keys named ca.crt, tls.crt and tls.key that
  # contain the CA, certificate and private key.
  # They will be generated if not set.
  secretName: ""

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
        cpu: 25m
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

rbac:
  create: false
serviceAccount:
  create: false
  name: ${service_account}
controller:
  publishService:
    enabled: true
  scope: 
    enabled: true
  service:
    type: LoadBalancer
    targetPorts:
      http: http
      https: http
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${cert_arn}"
      service.beta.kubernetes.io/aws-load-balancer-extra-security-groups: "${elb_security_group}"
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
      service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled: "true"
      service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout: "3600"
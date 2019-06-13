operators:
  slack: 
    image: docker.artifactory.liatr.io/liatrio/operator-slack:${image_tag}
    ingress:
      hostName: operator-slack.${ingress_domain}
      annotations:
        kubernetes.io/ingress.class: "nginx"
        kubernetes.io/tls-acme: "true"
      tls:
      - hosts:
        - operator-slack.${ingress_domain}
        secretName: operator-slack-ingress-tls
  jenkins: 
    image: docker.artifactory.liatr.io/liatrio/operator-jenkins:${image_tag}
  toolchain: 
    image: docker.artifactory.liatr.io/liatrio/operator-toolchain:${image_tag}
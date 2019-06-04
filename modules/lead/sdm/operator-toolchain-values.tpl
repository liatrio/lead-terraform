operators:
  slack: 
    image: docker.artifactory.liatr.io/liatrio/operator-slack:${image_tag}
    ingress:
      hostName: operator-slack.${ingress_domain}
  jenkins: 
    image: docker.artifactory.liatr.io/liatrio/operator-jenkins:${image_tag}
  toolchain: 
    image: docker.artifactory.liatr.io/liatrio/operator-toolchain:${image_tag}
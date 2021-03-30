image:
  repository: ${toolchain_image_repo}/sparky-mattermost
  tag: "${sparky_version}"

serviceAccount:
  create: false
  name: ${service_account}

bot:
  email: ${bot_email}
  username: ${bot_username}

kubernetes:
  productType: product-jenkins
  productNamespace: ${namespace}

mattermost:
  url: "http://mattermost-team-edition.${namespace}.svc.cluster.local:8065"
  websocketUrl: "ws://mattermost-team-edition.${namespace}.svc.cluster.local:8065"
  team: "liatrio"

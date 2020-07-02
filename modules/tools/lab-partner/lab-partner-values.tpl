cluster: ${cluster}
cluster_domain: ${cluster_domain}

secrets:
  slackSigningSecret: ${slack_client_signing_secret}
  slackBotUserOauthAccessToken: ${slack_bot_token}
  teamId: ${team_id}
ingress:
  host: lab-partner.${namespace}.${cluster_domain}

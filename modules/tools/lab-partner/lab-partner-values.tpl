secrets:
  slackSigningSecret: ${slack_client_signing_secret}
  slackBotUserOauthAccessToken: ${slack_bot_token}
  teamId: ${team_id}
ingress:
  host: lab-partner.${namespace}.${cluster_domain}
  annotations:
    kubernetes.io/ingress.class: ${namespace}-nginx
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"


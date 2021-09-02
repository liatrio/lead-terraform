rode:
  host: rode.${namespace}.svc.cluster.local:50051
  disableTransportSecurity: true

  auth:
    oidc:
      enabled: ${oidc_auth_enabled}
      clientId: ${oidc_client_id}
      tokenUrl: ${oidc_token_url}

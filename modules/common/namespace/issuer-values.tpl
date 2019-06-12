acme:
  enabled: ${ issuer_type == "acme" }
  server: https://acme-v02.api.letsencrypt.org/directory
  email: cloudservices@liatr.io
selfSigned:
  enabled: ${ issuer_type == "selfSigned" }
{
  "auths": {
    "${artifactory_url}": {
      "email": "${email}",
      "auth": "${artifactory_auth}"
    },
%{ if enable_harbor == "true" }
    "${harbor_url}": {
      "email": "${email}",
      "auth": "${harbor_auth}"
    }
  }
%{ endif }
}

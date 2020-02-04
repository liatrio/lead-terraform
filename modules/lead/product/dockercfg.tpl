{
  "auths": {
    "${artifactory_url}": {
      "email": "${email}",
      "auth": "${artifactory_auth}"
%{ if enable_harbor == "false" }
    }
%{ else }
    },
    "${harbor_url}": {
      "email": "${email}",
      "auth": "${harbor_auth}"
    }
%{ endif }
  }
}

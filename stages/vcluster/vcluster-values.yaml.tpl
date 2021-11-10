syncer:
  extraArgs:
    - --tls-san=${api_server_host}
    - --out-kube-config-server=https://${api_server_host}

volumes:
  - name: signing-cert-and-key
    secret:
      secretName: ${signing_cert_and_key_secret_name}

vcluster:
  extraArgs:
    - "--kube-apiserver-arg=service-account-issuer=https://${api_server_host}"
    - "--kube-apiserver-arg=external-hostname=${api_server_host}"
    - "--kube-apiserver-arg=service-account-jwks-uri=https://${api_server_host}/openid/v1/jwks"
    - "--kube-apiserver-arg=service-account-extend-token-expiration=false"
    - "--kube-controller-manager-arg=cluster-signing-cert-file=/signing-cert-and-key/cert.pem"
    - "--kube-controller-manager-arg=cluster-signing-key-file=/signing-cert-and-key/key.pem"
    - "--service-cidr=${host_cluster_service_cidr}"
  volumeMounts:
    - mountPath: /signing-cert-and-key
      name: signing-cert-and-key
    - mountPath: /data
      name: data
  # the aws-pod-identity-webhook creates a certificate that uses the legacy Common Name field
  # this env var is needed to prevent this from throwing an error when the apiserver hits the MAW
  env:
    - name: GODEBUG
      value: x509ignoreCN=0

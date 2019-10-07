CA Issuer Module

Generates a cert-manager issuer to generate self signed certificates

1. Generate CA private key [Terraform: tls_private_key](https://www.terraform.io/docs/providers/tls/r/private_key.html)
2. Generate self signed CA certificate [Terraform: tls_self_signed_cert](https://www.terraform.io/docs/providers/tls/r/self_signed_cert.html)
3. Store CA key and certificate in secret [Terraform: kubernetes_secret](https://www.terraform.io/docs/providers/kubernetes/r/secret.html)
4. Create Kubernetes Issuer resource

Reference 
Cert-Manager - CA Issuer [https://docs.cert-manager.io/en/latest/tasks/issuers/setup-ca.html](https://docs.cert-manager.io/en/latest/tasks/issuers/setup-ca.html)
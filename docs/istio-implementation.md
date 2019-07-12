# Istio Implementation

[Istio](https://istio.io) is installed on the cluster, and we are taking advantage of its [traffic management](https://istio.io/docs/concepts/traffic-management) capabilities for routing requests to the monolith and to the various microservices as the monolith is broken apart.

## Integration with cert-manager

[Cert-manager](https://docs.cert-manager.io/) is used to automatically provision TLS certificates with [Let's Encrypt](https://letsencrypt.org/). This requires that we create an Issuer resource in the `istio-`system namespace. This is done within the [istio module](modules/common/istio).

When each namespace is created, we create a Certificate resource that instructs cert-manager to provision a wildcard certificate for the domain (i.e., `*.chatops-dev-production.lead.prod.liatr.io`). The details of the issued certificate will be stored as a Secret in the `istio-system` namespace

For an overview of how cert-manager and Istio work together, see this Medium post: [Istio + cert-manager + Let’s Encrypt demystified](https://medium.com/@gregoire.waymel/istio-cert-manager-lets-encrypt-demystified-c1cbed011d67)

## Traffic Routing

Any application deployed within the namespace is responsible for creating a Gateway and VirtualService specific to the application. Both the Gateway and and VirtualService should specify a host with a name that matches the namespace's wildcard cert (i.e., `myapplication.chatops-dev-production.lead.prod.liatr.io`) External-dns will notice the host on the Gateway resource and generate the appropriate DNS entries in Route53.

The VirtualService should contain routing rules that determine how Istio will route traffic to the various services in the namespace.

For example:

    apiVersion: networking.istio.io/v1alpha3
    kind: VirtualService
    metadata:
      name: bookinfo
      namespace: jph-bookinfo-production
    spec:
      hosts:
      - "bookinfo.jph-bookinfo-production.lead.sandbox.liatr.io"
      gateways:
      - bookinfo-gateway
      http:
      - match:
        - uri:
            exact: /productpage
        - uri:
            prefix: /api/v1/products
        route:
        - destination:
            host: newservice
            port:
              number: 9080
      - route:
        destination:
          host: monolith
          port:
            number: 9080
        


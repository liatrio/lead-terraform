package kubernetes.admission

import data.kubernetes.namespaces
import input.request.object.metadata.annotations as annotations

deny[msg] {
    input.request.kind.kind = "Service"
    input.request.operation = "CREATE"
    input.request.object.spec.type = "LoadBalancer"
    namespace_sg = namespaces[input.request.namespace].metadata.annotations["opa.liatr.io/elb-extra-security-groups"]
    not annotations["service.beta.kubernetes.io/aws-load-balancer-security-groups"] = namespace_sg
    msg = sprintf("LoadBalancer Services in namespace %q must use security group %q", [input.request.namespace, namespace_sg])
}

deny[msg] {
    input.request.kind.kind = "Service"
    input.request.operation = "CREATE"
    input.request.object.spec.type = "LoadBalancer"
    namespace_cert = namespaces[input.request.namespace].metadata.annotations["opa.liatr.io/elb-ssl-cert"]
    not annotations["service.beta.kubernetes.io/aws-load-balancer-ssl-cert"] = namespace_cert
    msg = sprintf("LoadBalancer Services in namespace %q must use ssl cert %q", [input.request.namespace, namespace_cert])
}
package kubernetes.admission

good_service = {
        "request": {
            "kind": { "kind": "Service" },
            "operation": "CREATE",
            "namespace": "test-namespace",
            "object": {
                "metadata": {
                    "annotations": {
                        "service.beta.kubernetes.io/aws-load-balancer-security-groups": "sg-12345",
                        "service.beta.kubernetes.io/aws-load-balancer-ssl-cert": "XXXXXXXXXXXXXXXX"
                    }
                },
                "spec": {
                    "type": "LoadBalancer"
                }
            }
        }
    }


clusterip_service = {
        "request": {
            "kind": { "kind": "Service" },
            "operation": "CREATE",
            "namespace": "test-namespace",
            "object": {
                "spec": {
                    "type": "ClusterIP"
                }
            }
        }
    }

bad_service = {
        "request": {
            "kind": { "kind": "Service" },
            "operation": "CREATE",
            "namespace": "test-namespace",
            "object": {
                "spec": {
                    "type": "LoadBalancer"
                }
            }
        }
    }

namespace_with_elb_annotations = {
    "test-namespace": {
        "metadata": {
            "annotations": {
                "opa.liatr.io/elb-extra-security-groups": "sg-12345",
                "opa.liatr.io/elb-ssl-cert": "XXXXXXXXXXXXXXXX"
            }
        }
    }
}

namespace_without_elb_annotations = {
    "test-namespace": {
        "metadata": {
            "annotations": {
            }
        }
    }
}

test_service_namespace_without_annotations {
    concat(",",deny) = ""
        with input as bad_service 
        with data.kubernetes.namespaces as namespace_without_elb_annotations
}

test_service_missing_ssl_cert {
    concat(",",deny) != ""
        with input as bad_service 
        with data.kubernetes.namespaces as namespace_with_elb_annotations
}

test_service_clusterip {
    concat(",",deny) == ""
        with input as clusterip_service 
        with data.kubernetes.namespaces as namespace_with_elb_annotations
}

test_service_with_annotations {
    concat(",",deny) == ""
        with input as good_service 
        with data.kubernetes.namespaces as namespace_with_elb_annotations
}

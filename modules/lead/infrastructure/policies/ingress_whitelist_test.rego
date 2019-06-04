package kubernetes.admission

good_ingress = {
        "request": {
            "kind": { "kind": "Ingress" },
            "operation": "CREATE",
            "namespace": "test-namespace",
            "object": {
                "metadata": { "name": "test-ubuntu-ingress" },
                "spec": {
                    "rules": [
                        {
                            "host": "foo.test-namespace.liatr.io"
                        }
                    ]
                }
            }
        }
    }


bad_ingress = {
        "request": {
            "kind": { "kind": "Ingress" },
            "operation": "CREATE",
            "namespace": "test-namespace",
            "object": {
                "metadata": { "name": "test-bad-ingress" },
                "spec": {
                    "rules": [
                        {
                            "host": "foo.google.com"
                        }
                    ]
                }
            }
        }
    }

namespace_without_ingress_whitelist = {
    "test-namespace": {
        "metadata": {
            "annotations": {}
        }
    }
}
namespace_with_ingress_whitelist = {
    "test-namespace": {
        "metadata": {
            "annotations": {
                "opa.liatr.io/ingress-whitelist": "*.test-namespace.liatr.io"
            }
        }
    }
}

test_ingress_not_in_whitelist {
    concat(",",deny) != ""
        with input as bad_ingress 
        with data.kubernetes.namespaces as namespace_with_ingress_whitelist
}

test_ingress_no_whitelist {
    concat(",",deny) == ""
        with input as bad_ingress 
        with data.kubernetes.namespaces as namespace_without_ingress_whitelist
}

test_ingress_in_whitelist {
    concat(",",deny) == ""
        with input as good_ingress 
        with data.kubernetes.namespaces as namespace_with_ingress_whitelist
}

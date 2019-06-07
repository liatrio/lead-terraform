package kubernetes.admission

liatrio_pod = {
        "request": {
            "kind": { "kind": "Pod" },
            "operation": "CREATE",
            "namespace": "test-namespace",
            "object": {
                "metadata": { "name": "test-ubuntu-pod" },
                "spec": {
                    "containers": [
                        { "image": "docker.artifactory.liatr.io/liatrio/sample-app:v0.0.1" }
                    ]
                }
            }
        }
    }


ubuntu_pod = {
        "request": {
            "kind": { "kind": "Pod" },
            "operation": "CREATE",
            "namespace": "test-namespace",
            "object": {
                "metadata": { "name": "test-ubuntu-pod" },
                "spec": {
                    "containers": [
                        { "image": "ubuntu" }
                    ]
                }
            }
        }
    }

namespace_without_image_whitelist = {
    "test-namespace": {
        "metadata": {
            "annotations": {}
        }
    }
}
namespace_with_image_whitelist = {
    "test-namespace": {
        "metadata": {
            "annotations": {
                "opa.liatr.io/image-whitelist": "^docker.artifactory.liatr.io"
            }
        }
    }
}

test_image_not_in_whitelist {
    concat(",",deny) != ""
        with input as ubuntu_pod 
        with data.kubernetes.namespaces as namespace_with_image_whitelist
}

test_image_no_whitelist {
    concat(",",deny) == ""
        with input as ubuntu_pod 
        with data.kubernetes.namespaces as namespace_without_image_whitelist
}

test_image_in_whitelist {
    concat(",",deny) == ""
        with input as liatrio_pod 
        with data.kubernetes.namespaces as namespace_with_image_whitelist
}
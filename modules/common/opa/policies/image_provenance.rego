package kubernetes.admission

import data.kubernetes.namespaces

deny[msg] {
    input.request.kind.kind = "Pod"
    input.request.operation = "CREATE"
    image = input.request.object.spec.containers[_].image
    name = input.request.object.metadata.name

    whitelist = namespaces[input.request.namespace].metadata.annotations["opa.liatr.io/image-whitelist"]
    whitelist_set = split(whitelist, ",")

    not registry_whitelisted(image,whitelist_set)
    msg = sprintf("pod %q has invalid registry %q", [name, image])
}

registry_whitelisted(str, patterns) {
    registry_matches(str, patterns[_])
}

registry_matches(str, pattern) {
    re_match(pattern, str)
}
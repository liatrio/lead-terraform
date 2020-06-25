// Manage auth backends
path "auth/*" {
    capabilities = [
        "read",
        "list",
        "create",
        "update",
        "delete",
        "sudo"
    ]
}

path "sys/auth/*" {
    capabilities = [
        "read",
        "create",
        "update",
        "delete",
        "sudo"
    ]
}

// Manage policies
path "sys/policy/*" {
    capabilities = [
        "create",
        "read",
        "update",
        "delete",
        "list",
        "sudo"
    ]
}

// Manage secret backends
path "sys/mounts/*" {
    capabilities = [
        "create",
        "read",
        "update",
        "delete",
        "list",
        "sudo"
    ]
}

// Health checks
path "sys/health" {
    capabilities = [
        "read",
        "sudo"
    ]
}

// Basic read access to everything but secrets themselves
path "identity/*" {
    capabilities = [
        "read",
        "list"
    ]
}

path "sys/*" {
    capabilities = [
        "read",
        "list"
    ]
}

path "auth/*" {
    capabilities = [
        "read",
        "list"
    ]
}

// Create child tokens
path "auth/token/create" {
    capabilities = [
        "update"
    ]
}

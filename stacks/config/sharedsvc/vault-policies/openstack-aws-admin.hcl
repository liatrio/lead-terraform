// almost full access to /openstack/*

path "openstack/data/*" {
    capabilities = ["create", "update", "read", "delete"]
}

path "openstack/metadata/*" {
    capabilities = ["read", "list"]
}

path "openstack/delete/*" {
    capabilities = ["update"]
}

path "openstack/undelete/*" {
    capabilities = ["update"]
}

// list access for /openstack/*

path "openstack/metadata" {
    capabilities = ["read", "list"]
}

path "openstack/metadata/*" {
    capabilities = ["read", "list"]
}

// create child tokens

path "auth/token/create" {
    capabilities = ["update"]
}

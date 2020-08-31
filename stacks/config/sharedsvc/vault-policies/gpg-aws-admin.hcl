// read/write access to /gpg/*

path "gpg/data/*" {
    capabilities = ["create", "read"]
}

path "gpg/metadata/*" {
    capabilities = ["read", "list"]
}

// list access for /gpg/* and /gpg/* to make UI easier to use

path "gpg/metadata" {
    capabilities = ["read", "list"]
}

path "gpg/metadata" {
    capabilities = ["read", "list"]
}

// create child tokens

path "auth/token/create" {
    capabilities = ["update"]
}

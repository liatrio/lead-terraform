// almost full access to /lead/aws/account_id/*

path "lead/data/aws/{{identity.entity.aliases.${mount_accessor}.metadata.account_id}}/*" {
    capabilities = ["create", "update", "read", "delete"]
}

path "lead/metadata/aws/{{identity.entity.aliases.${mount_accessor}.metadata.account_id}}/*" {
    capabilities = ["read", "list"]
}

path "lead/delete/aws/{{identity.entity.aliases.${mount_accessor}.metadata.account_id}}/*" {
    capabilities = ["update"]
}

path "lead/undelete/aws/{{identity.entity.aliases.${mount_accessor}.metadata.account_id}}/*" {
    capabilities = ["update"]
}

// list access for /lead/* and /lead/aws/* to make UI easier to use

path "lead/metadata" {
    capabilities = ["read", "list"]
}

path "lead/metadata/aws" {
    capabilities = ["read", "list"]
}

// create child tokens

path "auth/token/create" {
    capabilities = ["update"]
}

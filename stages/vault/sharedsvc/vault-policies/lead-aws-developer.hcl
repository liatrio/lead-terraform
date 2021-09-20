// read access to a specific secret

path "lead/data/aws/{{identity.entity.aliases.${mount_accessor}.metadata.account_id}}/*" {
    capabilities = ["read"]
}

// list access for /lead/aws/account_id/*

path "lead/metadata/aws/{{identity.entity.aliases.${mount_accessor}.metadata.account_id}}/*" {
    capabilities = ["read", "list"]
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

variable "namespace" { }
variable "annotations" { 
    type = "map"
    default = {}
}
variable "labels" { 
    type = "map"
    default = {}
}
variable "issuer_type" { default = "selfSigned" }
variable "product_name" {} 
variable "root_zone_name" {}
variable "cluster" {
    default = "lead"
}
variable "image_whitelist" {
    default = ".*"
}

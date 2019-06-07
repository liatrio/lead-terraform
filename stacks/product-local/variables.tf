variable "product_name" {} 
variable "root_zone_name" {} 
variable "cluster" {
    default = "lead"
}
variable "region" {
    default = "us-east-1"
}
variable "image_whitelist" {
    default = ".*"
}
variable "vpc_name" {
    description = "vpc name"
    type        = string
}
variable "subnet_name" {
    description = "Subnet name"
    type        = string
}
variable "subnet_cidr" {
    description = "subent CIDR block"
    type        = string
}
variable "region" {
    description = "vpc region"
    type        = string
}
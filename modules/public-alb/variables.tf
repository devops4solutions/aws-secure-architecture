variable "ecs_cluster_name" {
  default = ""
}

variable "public_subnets" {
  type = list(any)
}

variable "vpc_id" {
  type    = string
  default = ""

}

variable "acm_certificate" {
  default = ""
}

variable "allow_ip" {}
variable "alb_name" {
}
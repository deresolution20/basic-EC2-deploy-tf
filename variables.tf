#defining workspace environment

variable "environment" {
  type    = list(string)
  default = ["dev", "stage", "prod"]
}

#defining cidr block for VPC

variable "vpc_id" {
  default = "10.0.0.0/16"
}


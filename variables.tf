#defining workspace environment


variable "environment" {
  type        = list(string)
  default     = ["dev", "stage", "prod"]
  description = "3 letter environment code applied to all top level resources"

}

#defining cidr block for VPC

variable "vpc_id" {
  type    = string
  default = "10.0.0.0/16"
}

#defining subnet cidr blocks and availability zones

variable "sub_cidr" {
  type = map(any)
  default = {
    public = {
      ip = "10.0.1.0/24"
      az = "us-west-2a"
    },
    private = {
      ip = "10.0.2.0/24"
      az = "us-west-2b"
    }
  }
}

variable "web_ingress" {
  type = map(object(
    {
      description = string
      port        = number
      protocol    = string
      cidr_blocks = list(string)
    }
  ))
  default = {
    "80" = {
      description = "Port 80"
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    "443" = {
      description = "Port 443"
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}



/* locals {
  ingress_rules = [{
    port        = 443
    description = "Port 443"
    },
    {
      port        = 80
      description = "Port 80"
    }
  ]
} */
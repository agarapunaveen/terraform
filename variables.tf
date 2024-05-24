variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "comman_tags" {
  
}

variable "project_name" {
  
}
variable "aws_subnet_public" {
  type = list
    validation {
      condition = length(var.aws_subnet_public) == 2
      error_message = "please enter the 2 subnets"
    }
}
variable "aws_subnet_private" {
  type = list
    validation {
      condition = length(var.aws_subnet_private) == 2
      error_message = "please enter the 2 subnets"
    }
}
variable "aws_subnet_database" {
  type= list
    validation {
      condition = length(var.aws_subnet_database) == 2
      error_message = "please enter the 2 subnets"
    }
}
variable "is_peering" {
  default = false
}

variable "target_vpc" {
  default = ""
}
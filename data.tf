data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default"{
    default = true
}

# data "route_table" "default" {
#   vpc_id=data.aws_vpc.default.id
# }
resource "aws_vpc_peering_connection" "peering" {
  count = var.target_vpc == "" ? 1 : 0
  peer_vpc_id   = var.target_vpc == "" ? data.aws_vpc.default.id : var.target_vpc.id
  vpc_id        = aws_vpc.main.id
  auto_accept = var.target_vpc == "" ? true : false

  tags = merge(
    var.comman_tags,
    {
        Name="${var.project_name}-peering"
    }
  )
}

resource "aws_route" "public_peering" {
    count = var.target_vpc == "" ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "private_peering" {
    count = var.target_vpc == "" ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

resource "aws_route" "database_peering" {
    count = var.target_vpc == "" ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
}

# resource "aws_route" "default_peering" {
#      count = var.target_vpc == "" ? 1 : 0
#   route_table_id            = data.route_table.default
#   destination_cidr_block    = var.cidr_block
#   vpc_peering_connection_id = aws_vpc_peering_connection.peering[0].id
# }
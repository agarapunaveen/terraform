resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = merge(
    var.comman_tags,
    {
    Name = "${var.project_name}-vpc"
  }
  )
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-gw"
  }
}

resource "aws_subnet" "public" {
    count = length(local.az_names)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.aws_subnet_public[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.comman_tags,
    {
    Name = "${var.project_name}-public-${local.az_names[count.index]}"
  }
  )
}

resource "aws_subnet" "private" {
    count = length(local.az_names)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.aws_subnet_private[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.comman_tags,
    {
    Name = "${var.project_name}-private-${local.az_names[count.index]}"
  }
  )
}

resource "aws_subnet" "database" {
    count = length(local.az_names)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.aws_subnet_database[count.index]
  availability_zone = local.az_names[count.index]
  tags = merge(
    var.comman_tags,
    {
    Name = "${var.project_name}-database-${local.az_names[count.index]}"
  }
  )
}


resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.comman_tags,
   
    {
        Name = "${var.project_name}"
    }
  )
}



resource "aws_eip" "nat" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.comman_tags,
    {
    Name = "${var.project_name}-nat"
  }
  )
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    var.comman_tags,
    {
    Name = "${var.project_name}-public-route-table"
  }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(
    var.comman_tags,
    {
    Name = "${var.project_name}-private-route-table"
  }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(
    var.comman_tags,
    {
    Name = "${var.project_name}-database-route-table"
  }
  )
}

resource "aws_route_table_association" "a" {
    count = length(var.aws_subnet_public)
  subnet_id      = element(aws_subnet.public[*].id,count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "b" {
    count = length(var.aws_subnet_private)
  subnet_id      = element(aws_subnet.private[*].id,count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "c" {
    count = length(var.aws_subnet_private)
  subnet_id      = element(aws_subnet.database[*].id,count.index)
  route_table_id = aws_route_table.database.id
}
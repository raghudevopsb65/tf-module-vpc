resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.PROJECT}-${var.ENV}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.PROJECT}-${var.ENV}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "igw-route-to-public-subnets" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "ngw-route-to-private-subnets" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_route" "peer-route-to-private-subnets" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = var.DEFAULT_VPC_CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "peer-route-to-public-subnets" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = var.DEFAULT_VPC_CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "peer-route-to-default-vpc-subnets" {
  route_table_id            = var.DEFAULT_VPC_RT
  destination_cidr_block    = var.VPC_CIDR
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}


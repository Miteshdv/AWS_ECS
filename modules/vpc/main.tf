resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = var.name
  }
}

resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in var.public_subnet_cidr_blocks : idx => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(var.public_subnet_cidr_blocks, each.key)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, each.key)
  tags = {
    Name = "${var.name}-public-${each.key}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.name}-public"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

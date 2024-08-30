resource "aws_vpc" "rq" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "private_subnet" {
  count             = 2
  cidr_block        = "10.0.${2+count.index}.0/24"
  availability_zone = var.available_azs.names[count.index]
  vpc_id            = aws_vpc.rq.id
}

resource "aws_subnet" "public_subnet" {
  count                   = 2
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = var.available_azs.names[count.index]
  vpc_id                  = aws_vpc.rq.id
  map_public_ip_on_launch = true
}

# chatgpt says i need all of these blocks
# oy vey
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.rq.id
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[0].id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.rq.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.rq.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "public_subnet" {
  count          = 2
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_subnet" {
  count          = 2
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "sg" {
  name        = "${var.app_name}-sg"
  description = "Security group for ECS task"
  vpc_id      = aws_vpc.rq.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

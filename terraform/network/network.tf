resource "aws_vpc" "NewVPC" {
  cidr_block            = "${var.vpc_cidr}"
  enable_dns_hostnames  = true
  tags {
    Name                = "test-vpc"
  }
}

## Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.NewVPC.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = "true"
  tags = {
    Name                  = "Public subnet"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = "${aws_vpc.NewVPC.id}"
  cidr_block              = "${var.public_subnet2_cidr}"
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = "true"
  tags = {
    Name                  = "Public subnet"
  }
}

## Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.NewVPC.id}"
  cidr_block        = "${var.private_subnet_cidr}"
  availability_zone = "${var.aws_region}c"
  tags = {
    Name            = "Private subnet"
  }
}

## Internet gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.NewVPC.id}"
  tags {
    Name = "VPC Ingernet Gateway"
  }
}

## Elastic IP for NAT GW
#resource "aws_eip" "nat_eip" {
#  vpc        = true
#  depends_on = ["aws_internet_gateway.gateway"]
#}

## NAT gateway
#resource "aws_nat_gateway" "gateway" {
#    allocation_id = "${aws_eip.nat_eip.id}"
#    subnet_id     = "${aws_subnet.public_subnet.id}"
#    depends_on    = ["aws_internet_gateway.gateway"]
#}

## Routing tables
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.NewVPC.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gateway.id}"
  }
  tags {
    Name       = "Public route table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id   = "${aws_vpc.NewVPC.id}"
#  route = {
#    cidr_block      = "0.0.0.0/0"
#    nat_gateway_id  = "aws_nat_gateway.gateway.id"
#  }
  tags {
    Name            = "Private route table"
  }
}

## Route tables associations
resource "aws_route_table_association" "public_subnet_association" {
    subnet_id       = "${aws_subnet.public_subnet.id}"
    route_table_id  = "${aws_route_table.public_route_table.id}"
}
resource "aws_route_table_association" "public_subnet2_association" {
    subnet_id       = "${aws_subnet.public_subnet2.id}"
    route_table_id  = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "private_subnet_association" {
    subnet_id       = "${aws_subnet.private_subnet.id}"
    route_table_id  = "${aws_route_table.private_route_table.id}"
}

#################
# Security Groups for Instance and ALB
#################
resource "aws_security_group" "instance" {
  name 					= "ssh and http"
	vpc_id				= "${aws_vpc.NewVPC.id}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
	egress {
		cidr_blocks = ["0.0.0.0/0"]
		protocol		= "-1"
		from_port		=	0
		to_port			= 0
	}
}

resource "aws_security_group" "alb" {
  name 					= "web-access"
	vpc_id				= "${aws_vpc.NewVPC.id}"
  ingress {
    from_port 	= 80
    to_port 		= 80
    protocol 		= "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
	egress {
		cidr_blocks = ["0.0.0.0/0"]
		protocol		= "-1"
		from_port		=	0
		to_port			= 0
	}
}
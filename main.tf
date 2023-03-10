# Create Custom VPC

resource "aws_vpc" "myplanet" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name    = var.project
    Project = var.project
  }
}


# Create IGW

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myplanet.id
  
  tags = {
    Name = var.project
    Project = var.project
  }
}


# Create Public Subnet 1

resource "aws_subnet" "public1" {
  vpc_id            	  = aws_vpc.myplanet.id
  cidr_block        	  = cidrsubnet(var.vpc_cidr, 3, 0)
  availability_zone 	  = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}-public1"
    Project = var.project
  }
}


# Create Public Subnet 2

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 1)
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}-public2"
    Project = var.project
  }
}


# Create Public Subnet 3

resource "aws_subnet" "public3" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 2)
  availability_zone       = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}-public3"
    Project = var.project
  }
}


# Create Private Subnet 1

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 3)
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project}-private1"
    Project = var.project
  }
}


# Create Private Subnet 2

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 4)
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name    = "${var.project}-private2"
    Project = var.project
  }
}


# Create Private Subnet 3

resource "aws_subnet" "private3" {
  vpc_id                  = aws_vpc.myplanet.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 3, 5)
  availability_zone       = data.aws_availability_zones.az.names[2]
  map_public_ip_on_launch = false

  tags = {
    Name    = "${var.project}-private3"
    Project = var.project
  }
}


# Create Public Route Table

resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.myplanet.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name    = "${var.project}-public"
    Project = var.project
  }  
}


# Associate Public 1 with Public RTB

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-rtb.id
}

# Associate Public 2 with Public RTB

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-rtb.id
}

# Associate Public 3 with Public RTB

resource "aws_route_table_association" "public3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.public-rtb.id
}


# Create Elastic IP

resource "aws_eip" "nat" {
  vpc      = true

  tags = {
    Name    = "${var.project}-nat-gw"
    Project = var.project
  }
}


# Create NAT Gateway

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name    = "${var.project}-nat"
    Project = var.project
  }
}


# Create Private Route Table

resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.myplanet.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name    = "${var.project}-private"
    Project = var.project
  }
}


# Associate Private 1 with Private RTB

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private-rtb.id
}


# Associate Private 2 with Private RTB

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private-rtb.id
}


# Associate Private 3 with Private RTB

resource "aws_route_table_association" "private3" {
  subnet_id      = aws_subnet.private3.id
  route_table_id = aws_route_table.private-rtb.id
}


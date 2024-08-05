
# Create a VPC
resource "aws_vpc" "Team1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Team1-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "team1_first_subnet" {
  vpc_id                  = aws_vpc.Team1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "team1-subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "team1_second_subnet" {
  vpc_id            = aws_vpc.Team1.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "team1-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "Team1" {
  vpc_id = aws_vpc.Team1.id

  tags = {
    Name = "team1-gateway"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.Team1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Team1.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.team1_first_subnet.id
  route_table_id = aws_route_table.public.id
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

# Create a NAT Gateway
resource "aws_nat_gateway" "Team1" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.team1_first_subnet.id

  tags = {
    Name = "team1-nat-gateway"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.Team1.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Team1.id
  }

  tags = {
    Name = "private-route-table"
  }
}

# Associate the route table with the private subnet
resource "aws_route_table_association" "private_subnet" {
  subnet_id      = aws_subnet.team1_second_subnet.id
  route_table_id = aws_route_table.private.id
}

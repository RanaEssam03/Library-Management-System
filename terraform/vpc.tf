resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "team1_first_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "team1-first-subnet"
  }
}

resource "aws_subnet" "team1_second_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "team1-second-subnet"
  }
}

# resource "aws_subnet" "eks_subnet" {
#   count             = 2
#   vpc_id            = aws_vpc.eks_vpc.id
#   cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
#   availability_zone = "us-east-1b"
# }

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.eks_vpc.id
}

resource "aws_route" "eks_route" {
  route_table_id         = aws_route_table.eks_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

resource "aws_route_table_association" "eks_subnet_association" {
  subnet_id      = aws_subnet.team1_first_subnet.id
  route_table_id = aws_route_table.eks_route_table.id
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}
# Create a NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.team1_second_subnet.id

  tags = {
    Name = "main-nat-gateway"
  }
}
# Create a route table for the private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
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


# # Associate the route table with the private subnet
# resource "aws_route_table_association" "private_subnet" {
#   subnet_id      = aws_subnet.rana_second_subnet.id
#   route_table_id = aws_route_table.private.id
# }

# Create a security group for the EKS nodes
resource "aws_security_group" "eks_nodes" {
  vpc_id = aws_vpc.eks_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-nodes-sg"
  }
}

# resource "aws_route_table_association" "eks_subnet_association" {
#   count          = 2
#   subnet_id      = aws_subnet.eks_subnet[count.index].id
#   route_table_id = aws_route_table.eks_route_table.id
# }



terraform {
  backend "s3" {
    bucket         = "teamm01"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # Optionally configure DynamoDB table for state locking
    dynamodb_table = "terraform-locks"
  }
}


provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  token                  = data.aws_eks_cluster_auth.main.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
}

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

# Create a security group
resource "aws_security_group" "eks" {
  vpc_id = aws_vpc.Team1.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 5173
    to_port     = 5173
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
    Name = "eks-sg"
  }
}

# Create an IAM role for EKS
resource "aws_iam_role" "eks" {
  name = "eks-cluster-role-team1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the Amazon EKS policy to the IAM role
resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role     = aws_iam_role.eks.name
}

# Create an IAM role for EKS Node Group
resource "aws_iam_role" "eks_node_group" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role     = aws_iam_role.eks_node_group.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role     = aws_iam_role.eks_node_group.name
}
resource "aws_iam_role_policy_attachment" "eks_node_group_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"  # Ensure this is the correct policy
  role     = aws_iam_role.eks_node_group.name
}


# Create EKS Cluster
resource "aws_eks_cluster" "Team1" {
  name     = "Team1-cluster"
  role_arn  = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.team1_first_subnet.id,
      aws_subnet.team1_second_subnet.id,
    ]
    security_group_ids = [aws_security_group.eks.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy
  ]
}

# Create EKS Node Group
resource "aws_eks_node_group" "Team1" {
  cluster_name    = aws_eks_cluster.Team1.name
  node_group_name = "Team1-node-group"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids       = [
    aws_subnet.team1_first_subnet.id,
    aws_subnet.team1_second_subnet.id,
  ]
  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }
}
#_________________
# Fetch EKS Cluster Auth
data "aws_eks_cluster_auth" "Team1" {
  name = aws_eks_cluster.Team1.name
}

data "aws_iam_policy_document" "eks_full_access" {
  statement {
    effect  = "Allow"
    actions = [
      "eks:DescribeCluster",
      "eks:ListClusters",
      "eks:ListNodegroups",
      "eks:ListFargateProfiles",
      "eks:ListUpdates",
      "eks:DescribeNodegroup",
      "eks:DescribeFargateProfile",
      "eks:DescribeUpdate",
      "eks:UpdateNodegroupConfig",
      "eks:UpdateNodegroupVersion",
      "eks:CreateNodegroup",
      "eks:CreateFargateProfile",
      "eks:DeleteNodegroup",
      "eks:DeleteFargateProfile",
      "eks:TagResource",
      "eks:UntagResource"
    ]
    resources = ["*"]
  }
}


# IAM Policy Document for Trusted Account and Users
data "aws_iam_policy_document" "trusted_account" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    # Allow specific users to assume the role
    principals {
      type        = "AWS"
      identifiers = var.user_arns
    }
  }
}
# IAM Role for Master Access
resource "aws_iam_role" "master_access_team_1" {
  name               = "masterPermissionRole"  
  assume_role_policy = data.aws_iam_policy_document.trusted_account.json  
  tags               = var.tags
}

resource "aws_iam_role_policy" "master_access_policy" {
  name   = "masterAccessPolicy"
  role   = aws_iam_role.master_access_team_1.id
  policy = data.aws_iam_policy_document.eks_full_access.json
}

# Variable for User ARNs
variable "user_arns" {
  description = "List of IAM User ARNs allowed to assume the role"
  type        = list(string)
  default     = [
    "arn:aws:iam::637423483309:user/basma",
    "arn:aws:iam::637423483309:user/gamila",
    "arn:aws:iam::637423483309:user/farah"
  ]
}

# Tags Variable
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    Environment = "Production"
    Team        = "Team1"
  }
}





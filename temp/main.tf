# provider "aws" {
#   region = "us-east-1"
# }

# provider "kubernetes" {
#   host                   = aws_eks_cluster.main.endpoint
#   token                  = data.aws_eks_cluster_auth.main.token
#   cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
# }

# # Create a VPC
# resource "aws_vpc" "main" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = true
#   enable_dns_hostnames = true

#   tags = {
#     Name = "main-vpc"
#   }
# }

# # Create a public subnet
# resource "aws_subnet" "rana_first_subnet" {
#   vpc_id                  = aws_vpc.main.id
#   cidr_block              = "10.0.1.0/24"
#   availability_zone       = "us-east-1a"
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "main-subnet"
#   }
# }

# # Create a private subnet
# resource "aws_subnet" "rana_second_subnet" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone = "us-east-1b"

#   tags = {
#     Name = "second-subnet"
#   }
# }

# # Create an internet gateway
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "main-gateway"
#   }
# }

# # Create a route table for the public subnet
# resource "aws_route_table" "public" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }

#   tags = {
#     Name = "public-route-table"
#   }
# }

# # Associate the route table with the public subnet
# resource "aws_route_table_association" "public_subnet" {
#   subnet_id      = aws_subnet.rana_first_subnet.id
#   route_table_id = aws_route_table.public.id
# }

# # Create an Elastic IP for the NAT Gateway
# resource "aws_eip" "nat" {
#   domain = "vpc"
# }

# # Create a NAT Gateway
# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.rana_first_subnet.id

#   tags = {
#     Name = "main-nat-gateway"
#   }
# }

# # Create a route table for the private subnet
# resource "aws_route_table" "private" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block     = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.main.id
#   }

#   tags = {
#     Name = "private-route-table"
#   }
# }

# # Associate the route table with the private subnet
# resource "aws_route_table_association" "private_subnet" {
#   subnet_id      = aws_subnet.rana_second_subnet.id
#   route_table_id = aws_route_table.private.id
# }

# # Create a security group for the EKS nodes
# resource "aws_security_group" "eks_nodes" {
#   vpc_id = aws_vpc.main.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "eks-nodes-sg"
#   }
# }



# # Create a security group for the Load Balancer
# resource "aws_security_group" "load_balancer" {
#   vpc_id = aws_vpc.main.id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "lb-sg"
#   }
# }

# # Create an IAM role for EKS
# resource "aws_iam_role" "eks" {
#   name = "eks-cluster-role-rana"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# # Attach the Amazon EKS policy to the IAM role
# resource "aws_iam_role_policy_attachment" "eks_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks.name
# }

# # Create an IAM role for EKS Node Group
# resource "aws_iam_role" "eks_node_group" {
#   name = "eks-node-group-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks_node_group.name
# }

# resource "aws_iam_role_policy_attachment" "eks_node_group_ecr" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks_node_group.name
# }

# resource "aws_iam_role_policy_attachment" "eks_node_group_cni" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks_node_group.name
# }

# # Create EKS Cluster
# resource "aws_eks_cluster" "main" {
#   name     = "main-cluster"
#   role_arn = aws_iam_role.eks.arn

#   vpc_config {
#     subnet_ids         = [aws_subnet.rana_first_subnet.id, aws_subnet.rana_second_subnet.id]
#     security_group_ids = [aws_security_group.eks_nodes.id]
#   }

#   depends_on = [aws_iam_role_policy_attachment.eks_policy]
# }

# # Create EKS Node Group
# resource "aws_eks_node_group" "main" {
#   cluster_name    = aws_eks_cluster.main.name
#   node_group_name = "main-node-group"
#   node_role_arn   = aws_iam_role.eks_node_group.arn
#   subnet_ids      = [aws_subnet.rana_first_subnet.id, aws_subnet.rana_second_subnet.id]

#   scaling_config {
#     desired_size = 1
#     max_size     = 3
#     min_size     = 1
#   }

#   depends_on = [aws_eks_cluster.main]
# }

# # Fetch EKS Cluster Auth
# data "aws_eks_cluster_auth" "main" {
#   name = aws_eks_cluster.main.name
# }

# # Kubernetes provider configuration
# #provider "kubernetes" {
#   #host                   = aws_eks_cluster.main.endpoint
#   #token                  = data.aws_eks_cluster_auth.main.token
#   #cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
# #}


provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.main.endpoint
  token                  = data.aws_eks_cluster_auth.main.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Create a public subnet
resource "aws_subnet" "rana_first_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "main-subnet"
  }
}

# Create a private subnet
resource "aws_subnet" "rana_second_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "second-subnet"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-gateway"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# Associate the route table with the public subnet
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.rana_first_subnet.id
  route_table_id = aws_route_table.public.id
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
}

# Create a NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.rana_first_subnet.id

  tags = {
    Name = "main-nat-gateway"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

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
  subnet_id      = aws_subnet.rana_second_subnet.id
  route_table_id = aws_route_table.private.id
}

# Create a security group
resource "aws_security_group" "eks" {
  vpc_id = aws_vpc.main.id

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
  name = "eks-cluster-role-rana"

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
resource "aws_eks_cluster" "main" {
  name     = "main-cluster"
  role_arn  = aws_iam_role.eks.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.rana_first_subnet.id,
      aws_subnet.rana_second_subnet.id,
    ]
    security_group_ids = [aws_security_group.eks.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy
  ]
}

# Create EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "main-node-group"
  node_role_arn   = aws_iam_role.eks_node_group.arn
  subnet_ids       = [
    aws_subnet.rana_first_subnet.id,
    aws_subnet.rana_second_subnet.id,
  ]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}

# Fetch EKS Cluster Auth
data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

# # Kubernetes provider configuration
# provider "kubernetes" {
#   host                   = aws_eks_cluster.main.endpoint
#   token                  = data.aws_eks_cluster_auth.main.token
#   cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
# }

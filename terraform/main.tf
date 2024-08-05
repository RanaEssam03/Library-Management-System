
terraform {
  backend "s3" {
    bucket         = "teamm01"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # Optionally configure DynamoDB table for state locking
    # dynamodb_table = "terraform-locks"
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

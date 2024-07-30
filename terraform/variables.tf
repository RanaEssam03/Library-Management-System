variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  default     = "main-eks-cluster"
}

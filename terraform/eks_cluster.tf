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
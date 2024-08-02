# Fetch EKS Cluster Auth
data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
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
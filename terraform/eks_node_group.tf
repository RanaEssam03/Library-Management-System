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
resource "aws_eks_node_group" "this" {
  cluster_name  = var.cluster_name
  node_role_arn = var.node_role_arn
  subnet_ids    = var.subnet_ids
  ami_type      = "AL2_x86_64"
  version       = var.k8s_version
  disk_size     = 20

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]


  tags = {
    Name = "${var.cluster_name}-nodegroup"
  }
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = {
    Name = var.cluster_name
    Environment = var.environment
  }

  depends_on = [var.cluster_role_arn]
}

output "cluster_id" {
  value = aws_eks_cluster.this.id
}

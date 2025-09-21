output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_role_arn" {
  value = module.iam.cluster_role_arn
}

output "node_role_arn" {
  value = module.iam.node_role_arn
}

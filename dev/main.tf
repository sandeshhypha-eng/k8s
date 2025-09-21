
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
  backend "s3" {
    bucket         = "dev-eks-state-hypha"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    use_lockfile   = true
  }
}

  provider "aws" {
    region = var.aws_region
  }

module "vpc" {
  source       = "../modules/vpc"
  vpc_cidr     = var.vpc_cidr
  cluster_name = var.cluster_name
}

module "iam" {
  source       = "../modules/iam"
  cluster_name = var.cluster_name
}

module "eks" {
  source         = "../modules/eks"
  cluster_name   = var.cluster_name
  cluster_role_arn = module.iam.cluster_role_arn
  k8s_version    = var.k8s_version
  subnet_ids     = module.vpc.private_subnet_ids
  environment    = var.environment
}

module "nodegroup" {
  source         = "../modules/nodegroup"
  cluster_name   = var.cluster_name
  node_role_arn  = module.iam.node_role_arn
  k8s_version    = var.k8s_version
  subnet_ids     = module.vpc.private_subnet_ids
  ssh_key_name   = var.ssh_key_name
}

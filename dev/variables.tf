variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
  default     = "dev-hypa-eks-cluster"
}

variable "cluster_role_arn" {
  description = "IAM role ARN for EKS cluster"
  type        = string
  default     = ""
}

variable "node_role_arn" {
  description = "IAM role ARN for EKS node group"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of private subnet IDs for EKS and node groups"
  type        = list(string)
  default     = []
}

variable "k8s_version" {
  description = "Kubernetes version for EKS node group"
  type        = string
  default     = "1.31"
}

variable "ssh_key_name" {
  description = "EC2 SSH key name for node group remote access"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment tag for resources (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  default     = ""
}



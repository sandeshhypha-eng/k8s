variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
  default     = "prod-hypa-eks-cluster"
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
  default     = "1.32"
}

variable "ssh_key_name" {
  description = "EC2 SSH key name for node group remote access"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment tag for resources (e.g., dev, prod)"
  type        = string
  default     = "prod"
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

variable "aws_session_token" {
  description = "AWS Session Token (optional)"
  type        = string
  default     = ""
}

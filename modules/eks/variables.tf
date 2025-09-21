variable "cluster_name" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "environment" {
  type = string
}

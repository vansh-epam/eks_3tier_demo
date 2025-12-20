variable "region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  default = "eks-3tier-demo"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "node_desired_size" {
  default = 2
}

variable "node_min_size" {
  default = 1
}

variable "node_max_size" {
  default = 4
}

variable "node_instance_type" {
  default = "t3.medium"
}
variable "name" {
  description = "The name will be used to prefix and tag the resources, e.g mydb"
}

variable "ami_name" {
  default = "cassandra"
}

variable "key_name" {}

variable "vpc_id" {
  description = "The VPC ID to use"
}

variable "subnets" {
  description = "A list of subnet IDs in which to launch a cassandra seed"
  type        = "list"
}

variable "seed_ips" {
  description = "The private IP addresses to give the cassandra seeds. Length must be the same as subnet_ids and the order must match the cidr block of the subnet_ids."
  type        = "list"
}

variable "ssh_private_key_path" {}

variable "security_groups" {
  description = "security groups to apply to the cassandra seeds"
  type        = "list"
  default     = []
}

variable "instance_type" {
  description = "The type of instances cassandra will be running on"
  default     = "m4.2xlarge"
}

variable "volume_type" {
  default = "gp2"
}

variable "volume_size" {
  description = "The size of the cassandra volumes in GB"
  default     = "50"
}

variable "bastion_host" {
  description = "bastion host used as a jump server to execute commands on the cassandra nodes when bootstrapping"
}

variable "bastion_user" {}

variable "profile" {
  description = "AWS profile from shared credentials file. Usually located at ~/.aws/credentials"
}

variable "name" {
  description = "the name of your stack, e.g. \"my-stack\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod-east\""
  default     = "development"
}

variable "key_name" {
  description = "the name of the ssh key to use, e.g. \"internal-key\""
}

variable "ssh_private_key_path" {
  description = "path to local ssh private key. used for connecting to bastion host"
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "us-east-1"
}

variable "cidr" {
  description = "the CIDR block to provision for the VPC, if set to something other than the default, both internal_subnets and external_subnets have to be defined as well"
  default     = "10.30.0.0/16"
}

variable "internal_subnets" {
  description = "a list of CIDRs for internal subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.30.0.0/19", "10.30.64.0/19", "10.30.128.0/19"]
}

variable "external_subnets" {
  description = "a list of CIDRs for external subnets in your VPC, must be set if the cidr variable is defined, needs to have as many elements as there are availability zones"
  default     = ["10.30.32.0/20", "10.30.96.0/20", "10.30.160.0/20"]
}

variable "availability_zones" {
  description = "a comma-separated list of availability zones, defaults to all AZ of the region, if set to something other than the defaults, both internal_subnets and external_subnets have to be defined as well"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion"
  default     = "t2.micro"
}

variable "bastion_user" {}
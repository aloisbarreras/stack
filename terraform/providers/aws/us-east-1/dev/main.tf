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

variable "cassandra_ami_name" {}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "vpc" {
  source             = "../../../../modules/aws/network/vpc"
  name               = "${var.name}"
  cidr               = "${var.cidr}"
  internal_subnets   = "${var.internal_subnets}"
  external_subnets   = "${var.external_subnets}"
  availability_zones = "${var.availability_zones}"
  environment        = "${var.environment}"
}

module "security_groups" {
  source      = "../../../../modules/aws/network/security-groups"
  name        = "${var.name}"
  vpc_id      = "${module.vpc.id}"
  environment = "${var.environment}"
  cidr        = "${var.cidr}"
}

module "bastion" {
  source          = "../../../../modules/aws/network/bastion"
  region          = "${var.region}"
  security_groups = "${module.security_groups.external_ssh},${module.security_groups.internal_ssh}"
  vpc_id          = "${module.vpc.id}"
  subnet_id       = "${element(module.vpc.external_subnets, 0)}"
  key_name        = "${var.key_name}"
  environment     = "${var.environment}"
}

module "cassandra" {
  source          = "../../../../modules/aws/data/cassandra"
  name            = "${var.name}"
  environment     = "${var.environment}"
  ami_name        = "${var.cassandra_ami_name}"
  key_name        = "${var.key_name}"
  subnets         = "${module.vpc.internal_subnets}"
  vpc_id          = "${module.vpc.id}"
  security_groups = "${module.security_groups.internal_ssh},${module.security_groups.allow_outbound}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "bastion_external_ip" {
  value = "${module.bastion.external_ip}"
}

output "internal_subnets" {
  value = "${module.vpc.internal_subnets}"
}

output "external_subnets" {
  value = "${module.vpc.external_subnets}"
}

output "cassandra_seed_ips" {
  value = "${module.cassandra.seed_ips}"
}

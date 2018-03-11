variable "name" {}
variable "environment" {}
variable "key_name" {}
variable "profile" {}

variable "region" {
  default = "us-east-2"
}

variable "cidr" {
  default = "10.30.0.0/16"
}

variable "internal_subnets" {
  default = ["10.30.0.0/19", "10.30.64.0/19", "10.30.128.0/19"]
  type    = "list"
}

variable "external_subnets" {
  default = ["10.30.32.0/20", "10.30.96.0/20", "10.30.160.0/20"]
  type    = "list"
}

variable "availability_zones" {
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
  type    = "list"
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "vpc" {
  source             = "github.com/aloisbarreras/stack/terraform/modules/aws/network/vpc"
  name               = "${var.name}"
  environment        = "${var.environment}"
  cidr               = "${var.cidr}"
  internal_subnets   = ["${var.internal_subnets}"]
  external_subnets   = ["${var.external_subnets}"]
  availability_zones = ["${var.availability_zones}"]
}

module "security_groups" {
  source      = "github.com/aloisbarreras/stack/terraform/modules/aws/network/security-groups"
  vpc_id      = "${module.vpc.id}"
  name        = "${var.name}"
  environment = "${var.environment}"
  cidr        = "${var.cidr}"
}

module "bastion" {
  source          = "github.com/aloisbarreras/stack/terraform/modules/aws/network/bastion"
  security_groups = "${module.security_groups.external_ssh},${module.security_groups.external_rdp}"
  vpc_id          = "${module.vpc.id}"
  key_name        = "${var.key_name}"
  subnet_id       = "${module.vpc.external_subnets[0]}"
  environment     = "${var.environment}"
}

output "bastion_ip" {
  value = "${module.bastion.external_ip}"
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "cidr_block" {
  value = "${module.vpc.cidr_block}"
}

output "internal_subnets" {
  value = "${module.vpc.internal_subnets}"
}

output "external_subnets" {
  value = "${module.vpc.external_subnets}"
}

output "subnets" {
  value = ["${module.vpc.external_subnets}", "${module.vpc.internal_subnets}"]
}

output "availability_zones" {
  value = "${module.vpc.availability_zones}"
}

output "internal_nat_ips" {
  value = ["${module.vpc.internal_nat_ips}"]
}

output "internal_nat_ids" {
  value = ["${module.vpc.internal_nat_ids}"]
}

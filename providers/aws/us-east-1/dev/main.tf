provider "aws" {
  region = "${var.region}"
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
}

module "bastion" {
  source             = "../../../../modules/aws/network/bastion"
  instance_type      = "${var.bastion_instance_type}"
  region             = "${var.region}"
  security_group_ids = "${module.security_groups.external_ssh}"
  vpc_id             = "${module.vpc.id}"
  subnet_id          = "${element(module.vpc.external_subnets, 0)}"
  key_name           = "${var.key_name}"
  environment        = "${var.environment}"
}

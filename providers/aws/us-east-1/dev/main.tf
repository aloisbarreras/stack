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
}

module "bastion" {
  source          = "../../../../modules/aws/network/bastion"
  instance_type   = "${var.bastion_instance_type}"
  region          = "${var.region}"
  security_groups = ["${module.security_groups.external_ssh}", "${module.security_groups.internal_ssh}", "${module.security_groups.allow_all_outbound}"]
  vpc_id          = "${module.vpc.id}"
  subnet_id       = "${element(module.vpc.external_subnets, 0)}"
  key_name        = "${var.key_name}"
  environment     = "${var.environment}"
}

module "cassandra" {
  source               = "../../../../modules/aws/data/cassandra"
  name                 = "${var.name}"
  key_name             = "${var.key_name}"
  ssh_private_key_path = "${var.ssh_private_key_path}"
  subnets              = "${module.vpc.internal_subnets}"
  vpc_id               = "${module.vpc.id}"
  security_groups      = ["${module.security_groups.internal_ssh}", "${module.security_groups.allow_all_outbound}"]
  bastion_host         = "${module.bastion.external_ip}"
  bastion_user         = "${var.bastion_user}"
}

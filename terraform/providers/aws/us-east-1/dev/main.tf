variable "name" {}
variable "environment" {}
variable "key_name" {}
variable "profile" {}

variable "region" {
  default = "us-east-1"
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
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
  type    = "list"
}

provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

module "vpc" {
  source             = "../../../../modules/aws/network/vpc"
  name               = "${var.name}"
  environment        = "${var.environment}"
  cidr               = "${var.cidr}"
  internal_subnets   = ["${var.internal_subnets}"]
  external_subnets   = ["${var.external_subnets}"]
  availability_zones = ["${var.availability_zones}"]
}

module "security_groups" {
  source      = "../../../../modules/aws/network/security-groups"
  vpc_id      = "${module.vpc.id}"
  name        = "${var.name}"
  environment = "${var.environment}"
  cidr        = "${var.cidr}"
}

module "bastion" {
  name            = "${var.name}"
  source          = "../../../../modules/aws/network/bastion"
  security_groups = "${module.security_groups.internal_redis},${module.security_groups.internal_psql},${module.security_groups.external_ssh},${module.security_groups.external_rdp}"
  vpc_id          = "${module.vpc.id}"
  key_name        = "${var.key_name}"
  subnet_id       = "${module.vpc.external_subnets[0]}"
  environment     = "${var.environment}"
}

module "rds" {
  source              = "../../../../modules/aws/data/rds"
  name                = "${var.name}"
  environment         = "${var.environment}"
  database_name       = "gitlabhq_production"
  engine              = "postgres"
  engine_version      = "9.6.6"
  username            = "gitlab"
  password            = "password"
  skip_final_snapshot = true
  subnets             = ["${module.vpc.internal_subnets}"]
  security_groups     = ["${module.security_groups.internal_psql}"]
  multi_az            = true
}

module "redis" {
  source               = "../../../../modules/aws/data/elasticache"
  name                 = "${var.name}"
  environment          = "${var.environment}"
  engine               = "redis"
  engine_version       = "3.2.10"
  port                 = 6379
  node_type            = "cache.t2.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  security_groups      = ["${module.security_groups.internal_redis}"]
  subnets              = ["${module.vpc.internal_subnets}"]
}

data "aws_ami" "centos" {
  owners           = ["aws-marketplace"]
  executable_users = ["self"]
  most_recent      = true

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }
}

resource "aws_instance" "gitlab" {
  ami                    = "${data.aws_ami.centos.id}"
  source_dest_check      = false
  instance_type          = "m3.medium"
  subnet_id              = "${module.vpc.external_subnets[0]}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${module.security_groups.internal_redis}", "${module.security_groups.external_ssh}", "${aws_security_group.gitlab.id}"]
  monitoring             = true

  tags {
    Name        = "${var.name}-gitlab"
    environment = "${var.environment}"
  }
}

resource "aws_instance" "nfs" {
  ami                    = "ami-6e9b5913"
  source_dest_check      = false
  instance_type          = "m3.medium"
  subnet_id              = "${module.vpc.external_subnets[0]}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${module.security_groups.internal_redis}", "${module.security_groups.external_ssh}", "${aws_security_group.gitlab.id}"]
  monitoring             = true

  tags {
    Name        = "${var.name}-gitlab"
    environment = "${var.environment}"
  }
}

resource "aws_security_group" "gitlab" {
  vpc_id = "${module.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "gitlab" {
  instance = "${aws_instance.gitlab.id}"
  vpc      = true
}

output "gitlab_ip" {
  value = "${aws_eip.gitlab.public_ip}"
}

resource "aws_eip" "nfs" {
  instance = "${aws_instance.nfs.id}"
  vpc      = true
}

output "nfs_ip" {
  value = "${aws_eip.nfs.public_ip}"
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

output "rds_endpoint" {
  value = ["${module.rds.endpoint}"]
}

output "cache_nodes" {
  value = "${module.redis.cache_nodes}"
}

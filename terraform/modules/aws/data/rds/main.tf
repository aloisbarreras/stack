variable "name" {}
variable "environment" {}
variable "database_name" {}
variable "engine" {}
variable "engine_version" {}
variable "username" {}
variable "password" {}
variable "multi_az" {}

variable "storage_type" {
  default = "gp2"
}

variable "allocated_storage" {
  default = 50
}

variable "instance_class" {
  default = "db.t2.micro"
}

variable "publicly_accessible" {
  default = false
}

variable "skip_final_snapshot" {
  default = false
}

variable "subnets" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

locals {
  db_subnet_group_name = "${var.name}-subnet-group"
}

resource "aws_db_subnet_group" "main" {
  name       = "${local.db_subnet_group_name}"
  subnet_ids = ["${var.subnets}"]

  tags {
    Name = "${local.db_subnet_group_name}"
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.name}-${var.environment}-${var.engine}"
  allocated_storage      = "${var.allocated_storage}"
  storage_type           = "${var.storage_type}"
  engine                 = "${var.engine}"
  engine_version         = "${var.engine_version}"
  instance_class         = "${var.instance_class}"
  name                   = "${var.database_name}"
  username               = "${var.username}"
  password               = "${var.password}"
  db_subnet_group_name   = "${local.db_subnet_group_name}"
  vpc_security_group_ids = ["${var.security_groups}"]
  publicly_accessible    = "${var.publicly_accessible}"
  skip_final_snapshot    = "${var.skip_final_snapshot}"
  multi_az               = "${var.multi_az}"

  depends_on = ["aws_db_subnet_group.main"]

  tags {
    environment = "${var.environment}"
  }
}

output "endpoint" {
  value = "${aws_db_instance.main.endpoint}"
}

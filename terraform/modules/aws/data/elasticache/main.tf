variable "name" {}
variable "environment" {}
variable "engine" {}
variable "engine_version" {}
variable "node_type" {}
variable "port" {}
variable "num_cache_nodes" {}
variable "parameter_group_name" {}

variable "security_groups" {
  type = "list"
}

variable "subnets" {
  type = "list"
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = "${var.name}-${var.engine}"
  engine               = "${var.engine}"
  engine_version       = "${var.engine_version}"
  node_type            = "${var.node_type}"
  port                 = "${var.port}"
  num_cache_nodes      = "${var.num_cache_nodes}"
  parameter_group_name = "${var.parameter_group_name}"
  security_group_ids   = ["${var.security_groups}"]
  subnet_group_name    = "${aws_elasticache_subnet_group.main.name}"

  tags {
    environment = "${var.environment}"
  }
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.name}-${var.environment}-${var.engine}-elasticache-subnet-group"
  subnet_ids = ["${var.subnets}"]
}

output "cache_nodes" {
  value = "${aws_elasticache_cluster.main.cache_nodes}"
}

variable "ami_name" {}
variable "key_name" {}

variable "name" {
  description = "The name will be used to prefix and tag the resources, e.g mydb"
}

variable "environment" {
  description = "Environment tag, e.g prod"
}

variable "vpc_id" {
  description = "The VPC ID to use"
}

variable "subnets" {
  type = "list"
  description = "comma separated string of subnet IDs in which to launch a cassandra seed"
}

variable "security_groups" {
  default     = ""
  description = "comma separated string of additional security groups to apply to the cassandra nodes"
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

// Network Interfaces
resource "aws_network_interface" "seed" {
  count           = "${length(var.subnets)}"
  subnet_id       = "${element(var.subnets, count.index)}"
  security_groups = ["${split(",", var.security_groups)}", "${aws_security_group.cassandra_internal.id}"]

  tags {
    Environment = "${var.environment}"
  }
}

// Security Groups
resource "aws_security_group" "cassandra_internal" {
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${var.name}-cassandra-internal"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "allow_internode" {
  type                     = "ingress"
  from_port                = 7000
  to_port                  = 7000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cassandra_internal.id}"
  source_security_group_id = "${aws_security_group.cassandra_internal.id}"
}

resource "aws_security_group_rule" "allow_internode_ssl" {
  type                     = "ingress"
  from_port                = 7001
  to_port                  = 7001
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cassandra_internal.id}"
  source_security_group_id = "${aws_security_group.cassandra_internal.id}"
}

// Cassandra Seed Instances
resource "aws_instance" "cassandra_seed" {
  count         = "${length(var.subnets)}"
  ami           = "${data.aws_ami.cassandra.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  user_data     = "${element(data.template_file.user_data.*.rendered, count.index)}"

  network_interface {
    network_interface_id = "${element(aws_network_interface.seed.*.id, count.index)}"
    device_index         = 0
  }

  tags {
    Name        = "${var.name}-${format("cassandra-seed-%03d", count.index+1)}"
    Environment = "${var.environment}"
  }
}

output "seed_ips" {
  value = ["${aws_instance.cassandra_seed.*.private_ip}"]
}

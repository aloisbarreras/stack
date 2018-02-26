# Define security group for cassandra  cluster

resource "aws_security_group" "cassandra_internal" {
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_internode_communication" {
  type                     = "ingress"
  from_port                = 7000
  to_port                  = 7000
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cassandra_internal.id}"
  source_security_group_id = "${aws_security_group.cassandra_internal.id}"
}

resource "aws_security_group_rule" "allow_internode_communication_ssl" {
  type                     = "ingress"
  from_port                = 7001
  to_port                  = 7001
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.cassandra_internal.id}"
  source_security_group_id = "${aws_security_group.cassandra_internal.id}"
}

resource "aws_security_group" "allow_client_traffic" {
  vpc_id = "${var.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_9042" {
  count                    = "${length(var.allow_traffic_from)}"
  type                     = "ingress"
  from_port                = 9042
  to_port                  = 9042
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.allow_client_traffic.id}"
  source_security_group_id = "${element(var.allow_traffic_from, count.index)}"
}

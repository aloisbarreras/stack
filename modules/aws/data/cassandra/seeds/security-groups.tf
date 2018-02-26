# Define security group for cassandra  cluster

resource "aws_security_group" "cassandra_internal" {
  name   = "cassandra_internal"
  vpc_id = "${var.vpc_id}"
}

# Define sg rules

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

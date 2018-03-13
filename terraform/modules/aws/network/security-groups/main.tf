/**
 * Creates basic security groups to be used by instances and ELBs.
 */

variable "name" {
  description = "The name of the security groups serves as a prefix, e.g stack"
}

variable "vpc_id" {
  description = "The VPC ID"
}

variable "environment" {
  description = "The environment, used for tagging, e.g prod"
}

variable "cidr" {
  description = "The cidr block to use for internal security groups"
}

resource "aws_security_group" "allow_outbound" {
  name        = "${format("%s-%s-allow-outbound", var.name, var.environment)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows outbound traffic"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s allow outbound", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "internal_elb" {
  name        = "${format("%s-%s-internal-elb", var.name, var.environment)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows internal ELB traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s internal elb", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "external_elb" {
  name        = "${format("%s-%s-external-elb", var.name, var.environment)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows external ELB traffic"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s external elb", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "internal_ssh" {
  name        = "${format("%s-%s-internal-ssh", var.name, var.environment)}"
  description = "Allows ssh from bastion"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.external_ssh.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s internal ssh", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "external_ssh" {
  name        = "${format("%s-%s-external-ssh", var.name, var.environment)}"
  description = "Allows ssh from the world"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s external ssh", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "internal_rdp" {
  name        = "${format("%s-%s-internal-rdp", var.name, var.environment)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows rdp from bastion"

  ingress {
    from_port       = 3389
    to_port         = 3389
    protocol        = "tcp"
    security_groups = ["${aws_security_group.external_rdp.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s internal rdp", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "external_rdp" {
  name        = "${format("%s-%s-external-rdp", var.name, var.environment)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows rdp from the world"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s external rdp", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "internal_psql" {
  name        = "${format("%s-%s-internal-psql", var.name, var.environment)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows incoming and outgoing psql traffic"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s internal psql", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "psql_ingress" {
  type      = "ingress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.internal_psql.id}"
  security_group_id        = "${aws_security_group.internal_psql.id}"
}

resource "aws_security_group_rule" "psql_egress" {
  type      = "egress"
  from_port = 5432
  to_port   = 5432
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.internal_psql.id}"
  security_group_id        = "${aws_security_group.internal_psql.id}"
}

resource "aws_security_group" "external_psql" {
  name        = "${format("%s-%s-external-psql", var.name, var.environment)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows psql traffic from the world"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s external psql", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "internal_redis" {
  name        = "${format("%s-%s-internal-redis", var.name, var.environment)}"
  vpc_id      = "${var.vpc_id}"
  description = "Allows incoming and outgoing redis traffic"

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name        = "${format("%s internal redis", var.name)}"
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "redis_ingress" {
  type      = "ingress"
  from_port = 6379
  to_port   = 6379
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.internal_redis.id}"
  security_group_id        = "${aws_security_group.internal_redis.id}"
}

resource "aws_security_group_rule" "redis_egress" {
  type      = "egress"
  from_port = 6379
  to_port   = 6379
  protocol  = "tcp"

  source_security_group_id = "${aws_security_group.internal_redis.id}"
  security_group_id        = "${aws_security_group.internal_redis.id}"
}

// Allow Outbound allows all outgoing traffic
output "allow_outbound" {
  value = "${aws_security_group.allow_outbound.id}"
}

// Internal ELB allows internal traffic.
output "internal_elb" {
  value = "${aws_security_group.internal_elb.id}"
}

// External ELB allows traffic from the world.
output "external_elb" {
  value = "${aws_security_group.external_elb.id}"
}

// Internal SSH allows ssh connections from the external ssh security group.
output "internal_ssh" {
  value = "${aws_security_group.internal_ssh.id}"
}

// External SSH allows ssh connections on port 22 from the world.
output "external_ssh" {
  value = "${aws_security_group.external_ssh.id}"
}

// Internal RDP allows windows rdp connections from the vpc
output "internal_rdp" {
  value = "${aws_security_group.internal_rdp.id}"
}

// External RDP allows windows rdp connections on port 3389 from the world.
output "external_rdp" {
  value = "${aws_security_group.external_rdp.id}"
}

// Internal PSQL allows postgres psql connections on port 5432
output "internal_psql" {
  value = "${aws_security_group.internal_psql.id}"
}

// External PSQL allows postgres psql connections on port 5432 from the world
output "external_psql" {
  value = "${aws_security_group.external_psql.id}"
}

// Internal Redis allows redis connections on port 6379
output "internal_redis" {
  value = "${aws_security_group.internal_redis.id}"
}

data "aws_ami" "cassandra" {
  most_recent = true

  executable_users = ["self"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["${var.ami_name}*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  seed_ips = ["${flatten(aws_network_interface.seed.*.private_ips)}"]
}

data "template_file" "user_data" {
  count    = "${length(var.subnets)}"
  template = "${file("${path.module}/templates/init.tpl")}"

  vars {
    cluster_name   = "${var.name}"
    seeds          = "${join(",", local.seed_ips)}"
    listen_address = "${element(local.seed_ips, count.index)}"
    rpc_address    = "${element(local.seed_ips, count.index)}"
  }
}

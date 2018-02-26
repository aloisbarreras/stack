data "aws_ami" "cassandra" {
  most_recent = true

  executable_users = ["self"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["${var.ami_name}-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "cassandra_seed_yaml" {
  count    = "${length(var.subnets)}"
  template = "${file("${path.module}/templates/cassandra.yaml.tpl")}"

  vars {
    cluster_name   = "${var.name}"
    seeds          = "${join(",", module.seed_enis.private_ips)}"
    listen_address = "${element(module.seed_enis.private_ips, count.index)}"
    rpc_address    = "${element(module.seed_enis.private_ips, count.index)}"
  }
}

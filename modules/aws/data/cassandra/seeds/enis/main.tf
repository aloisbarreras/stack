variable "subnets" {
  type = "list"
}

variable "security_groups" {
  type = "list"
}

resource "aws_network_interface" "seed" {
  count           = "${length(var.subnets)}"
  subnet_id       = "${element(var.subnets, count.index)}"
  security_groups = ["${var.security_groups}"]
}

output "ids" {
  value = ["${aws_network_interface.seed.*.id}"]
}

output "private_ips" {
  value = ["${flatten(aws_network_interface.seed.*.private_ips)}"]
}

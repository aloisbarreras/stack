module "enis" {
  source          = "./enis"
  subnets         = ["${var.subnets}"]
  security_groups = ["${var.security_groups}", "${aws_security_group.cassandra_internal.id}", "${aws_security_group.allow_client_traffic.id}"]
}

resource "aws_instance" "cassandra_seed" {
  count         = "${length(var.subnets)}"
  ami           = "${data.aws_ami.cassandra.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"

  network_interface {
    network_interface_id = "${element(module.enis.ids, count.index)}"
    device_index         = 0
  }

  tags {
    Name = "${var.name}-cassandra-seed-${count.index}"
  }

  provisioner "file" {
    content     = "${element(data.template_file.cassandra_seed_yaml.*.rendered, count.index)}"
    destination = "/tmp/cassandra.yaml"

    connection {
      type                = "ssh"
      user                = "centos"
      bastion_host        = "${var.bastion_host}"
      bastion_private_key = "${file(var.ssh_private_key_path)}"
      bastion_user        = "${var.bastion_user}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/cassandra.yaml /etc/cassandra/conf/cassandra.yaml",
      "sudo echo \"auto_bootstrap: false\" >> /etc/cassandra/conf/cassandra.yaml",
      "sudo chkconfig cassandra on",
      "sudo systemctl enable cassandra",
      "sudo systemctl start cassandra",
    ]

    connection {
      type                = "ssh"
      user                = "centos"
      bastion_host        = "${var.bastion_host}"
      bastion_private_key = "${file(var.ssh_private_key_path)}"
      bastion_user        = "${var.bastion_user}"
    }
  }
}

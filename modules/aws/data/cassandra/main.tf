resource "aws_instance" "cassandra_seed" {
  count                  = "${length(var.seed_ips)}"
  subnet_id              = "${element(var.subnets, count.index)}"
  ami                    = "${data.aws_ami.cassandra.id}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  private_ip             = "${element(var.seed_ips, count.index)}"
  vpc_security_group_ids = ["${var.security_groups}", "${aws_security_group.cassandra_internal.id}"]

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

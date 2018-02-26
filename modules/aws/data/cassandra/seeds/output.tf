output "ips" {
  value = ["${aws_instance.cassandra_seed.*.private_ip}"]
}
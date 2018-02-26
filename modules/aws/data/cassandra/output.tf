output "seed_ips" {
  value = ["${aws_instance.cassandra_seed.*.private_ip}"]
}
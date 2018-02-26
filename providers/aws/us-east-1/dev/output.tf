output "vpc_id" {
  value = "${module.vpc.id}"
}

output "bastion_external_ip" {
  value = "${module.bastion.external_ip}"
}

output "internal_subnets" {
  value = "${module.vpc.internal_subnets}"
}

output "cassandra_seed_ips" {
  value = ["${module.cassandra.seed_ips}"]
}

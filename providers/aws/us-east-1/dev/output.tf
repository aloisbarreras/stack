output "vpc_id" {
  value = "${module.vpc.id}"
}

output "bastion_external_ip" {
  value = "${module.bastion.external_ip}"
}
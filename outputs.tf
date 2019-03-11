output "private_ip" {
  value = ["${module.instance_ec2.private_ip}"]
}

output "private_dns" {
  value = ["${module.instance_ec2.private_dns}"]
}
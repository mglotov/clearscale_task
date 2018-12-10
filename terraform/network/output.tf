output "vpc_id" {
  value = "${aws_vpc.NewVPC.id}"
}
output "public_subnet" {
  value = "${var.public_subnet_cidr}"
}
output "public_subnet_id" {
  value = "${aws_subnet.public_subnet.id}"
}
output "public_subnet2_id" {
  value = "${aws_subnet.public_subnet2.id}"
}
output "private_subnet_id" {
  value = "${aws_subnet.private_subnet.id}"
}
#output "NAT GW Elastic IP" {
#  value = "${aws_eip.nat_eip.id}"
#}

output "instance_security_group_id" {
  value = "${aws_security_group.instance.id}"
}
output "alb_security_group_id" {
  value = "${aws_security_group.alb.id}"
}
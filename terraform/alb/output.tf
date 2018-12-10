output "target_groups_arn" {
  value = "${aws_lb_target_group.alb_target_group.arn}"
}
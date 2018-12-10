resource "aws_key_pair" "first-key" {
  key_name   = "first-key"
  public_key = "${file("asg/ssh-key.pub")}"
}
resource "aws_launch_configuration" "autoscale_launch" {
  image_id 								= "${var.aws_ami}"
  name_prefix 						= "launch-config-"
  instance_type 					= "t2.micro"
	iam_instance_profile 		= "${var.instance_profile}"
  security_groups 				= ["${var.instance_security_group}"]
  key_name 								= "${aws_key_pair.first-key.id}"
  lifecycle {
    create_before_destroy = true
  }
	user_data = <<-EOF
	#!/bin/bash
	SNS_ARN=`aws ssm get-parameter --region us-west-1 --name arn_sns_topic --output text --query Parameter.Value`
	sed -i "s/arn_from_secret/$SNS_ARN/" /var/www/html/index.php 
	EOF
}

resource "aws_autoscaling_group" "autoscale_group" {
	name 									= "${aws_launch_configuration.autoscale_launch.name}-asg"
  launch_configuration 	= "${aws_launch_configuration.autoscale_launch.id}"
  vpc_zone_identifier 	= ["${var.public_subnet}"] # Needs to check that all works correctly. For SSH access
#  vpc_zone_identifier = "${var.private_subnet}" # Set if you don't need direct access to instances
	target_group_arns 		= ["${var.target_groups_arn}"] 
  min_size 							= 1
  max_size 							= 1
  tag {
    key 								= "Name"
    value 							= "autoscale"
    propagate_at_launch = true
  }
}
provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
}

terraform {
  backend "s3" {
    bucket  = "my-terraform-task"
    key     = "terraform/terraform.tfstate"
    region  = "us-west-1"
  }
}

module "network" {
  source      = "network"
  aws_region  = "${var.aws_region}"
}

module "iam" {
  source = "iam"
}

module "asg" {
  source                  = "asg"
  instance_security_group = "${module.network.instance_security_group_id}"
  public_subnet           = "${module.network.public_subnet_id}"
  private_subnet          = "${module.network.private_subnet_id}"
  target_groups_arn       = "${module.alb.target_groups_arn}"
  aws_ami                 = "${var.ami_image_id}"
  instance_profile        = "${module.iam.instance_profile_name}"
}

module "alb" {
  source = "alb"
  public_subnet           = "${module.network.public_subnet_id}"
  public_subnet2          = "${module.network.public_subnet2_id}"
  alb_security_group      = "${module.network.alb_security_group_id}"
  vpc                     = "${module.network.vpc_id}"
  asg_id                  = "${module.asg.asg_id}"
}
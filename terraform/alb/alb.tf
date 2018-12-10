resource "aws_lb" "alb" {  
  name                = "alb"  
  subnets             = ["${var.public_subnet}", "${var.public_subnet2}"]
  security_groups     = ["${var.alb_security_group}"]
  load_balancer_type  = "application"
  internal            = false
  idle_timeout        = 60   
  tags {    
    Name              = "alb"    
  }   
}

resource "aws_lb_target_group" "alb_target_group" {  
  name      = "alb-target-group"  
  port      = "80"  
  protocol  = "HTTP"  
  vpc_id    = "${var.vpc}"   
  tags {    
    name    = "alb_target_group"    
  }   
  health_check {    
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path                = "/"    
    port                = 80
  }
}

resource "aws_lb_listener" "alb_listener" {  
  load_balancer_arn = "${aws_lb.alb.arn}"  
  port              = 80  
  protocol          = "HTTP"
  
  default_action {    
    target_group_arn = "${aws_lb_target_group.alb_target_group.arn}"
    type             = "forward"  
  }
}

resource "aws_autoscaling_attachment" "alb_autoscale" {
  alb_target_group_arn   = "${aws_lb_target_group.alb_target_group.arn}"
  autoscaling_group_name = "${var.asg_id}"
}
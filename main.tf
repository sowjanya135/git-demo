 provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "web" {
  ami           = "var.ami"
  instance_type = "var.instance_type"
  vpc_security_group_ids = ["${aws_security_group.http.id}"]
  key_name = "var.key_name"
  user_data = <<-EOF
          #! /bin/bash
          sudo yum install -y httpd
          sudo systemctl start httpd
          sudo systemctl enable httpd
  EOF

  tags = {
    Name = "instance"
  }
}

resource "aws_security_group" "http" {
  name        = "test-sg"
  description = "Allow 2 ports"

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description      = lookup(ingress.value, "description", null)
      from_port        = lookup(ingress.value, "from_port", null)
      to_port          = lookup(ingress.value, "to_port", null)
      protocol         = lookup(ingress.value, "protocol", null)
      cidr_blocks      = lookup(ingress.value, "cidr_blocks", null)
    }
  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Allow HTTP Security Group"
  }
}

resource "aws_ami_from_instance" "example" {
  name               = "terraform-example"
  source_instance_id = "${aws_instance.web.id}"

  #depends_on = [
     # aws_instance.web,
 # ]
}


#creating ALB

resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-test-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "vpc-91a4a6f9"
}

resource "aws_lb" "my-aws-alb" {
  name     = "my-test-alb"
  internal = false

  security_groups = [
    "${aws_security_group.http.id}",
  ]

  subnets = [
    "subnet-c86a5fa0",
    "subnet-090d6e73"
  ]

  tags = {
    Name = "my-test-alb"
  }

  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_lb_listener" "my-test-alb-listner" {
  load_balancer_arn = "${aws_lb.my-aws-alb.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.my-target-group.arn}"
  }
}

resource "aws_lb_target_group_attachment" "test" {
    target_group_arn = aws_lb_target_group.my-target-group.arn
    target_id        = aws_instance.web.id
    port             = 80
}


#creating auto-scaling-group

data "aws_ami" "linux" {
  most_recent = true

#  filter {
#   name   = "terraform-example"
#  }

  owners = ["633025986259"] # Canonical
}

resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "terraform-lc"
  image_id      = data.aws_ami.linux.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bar" {
  name                 = "terraform-asg-example"
  launch_configuration = aws_launch_configuration.as_conf.name
  min_size             = 0
  desired_capacity     = 0
  max_size             = 2
  vpc_zone_identifier  = ["subnet-c86a5fa0"]

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.bar.id
  #alb                    = aws_lb.my-aws-alb.id
  lb_target_group_arn    = aws_lb_target_group.my-target-group.arn

}



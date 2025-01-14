provider "aws" {
region = "ap-southeast-2"
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = "terraform-aws-state-sandbox"
    key = "stage/data-stores/mysql/terraform.tfstate"
    region = "ap-southeast-2"
 }
}

resource "aws_launch_configuration" "example" {
image_id         = "ami-002aaaf5ff99b864b"
instance_type    = "t2.micro"
security_groups  = [aws_security_group.instance.id]
user_data = <<-EOF
            #!/bin/bash
            sudo apt update -y
            sudo apt install -y apache2
            sudo systemctl start apache2
            sudo systemctl enable apache2            
            sudo echo '<center><h1>This Apache Web Server is Running on an AWS EC2 Instance </h1></center>' > /var/www/html/index.html
            sudo echo '${data.terraform_remote_state.db.outputs.address}' >> /var/www/html/index.html
            sudo echo '${data.terraform_remote_state.db.outputs.port}' >> /var/www/html/index.html
            sudo systemctl restart apache2
            sudo ufw disable
            EOF
lifecycle {
  create_before_destroy = true
}
}
data "aws_vpc" "selected" {
  id = var.vpc_id
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}
resource "aws_autoscaling_group" "example" {
 launch_configuration = aws_launch_configuration.example.name
 vpc_zone_identifier = data.aws_subnets.default.ids
 target_group_arns = [aws_lb_target_group.asg.arn]
 health_check_type = "ELB"
 min_size = 2
 max_size = 3
 tag {
 key = "Name"
 value = "terraform-asg-example"
 propagate_at_launch = true
}
}
resource "aws_lb" "example" {
  name = "terraform-asg-example"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"
  default_action {
  type = "fixed-response"
  fixed_response {
    content_type = "text/plain"
    message_body = "404: page not found"
    status_code = 404
  }
 }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
     condition {
       path_pattern {
       values = ["*"]
     }
   }
    action {
      type = "forward"
      target_group_arn = aws_lb_target_group.asg.arn
    }
 }


resource "aws_security_group" "alb" {
 name = "terraform-example-alb"
 ingress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_security_group" "instance" {
 name = "terraform-example-instance"
 ingress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
 }
 egress {
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-example"
  port = 80
  protocol = "HTTP"
  vpc_id = data.aws_vpc.selected.id
  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

terraform {
  backend "s3" {
    bucket =  "terraform-aws-state-sandbox"
    key = "stage/services/webserver-cluster/terraform.tfstate"
    region = "ap-southeast-2"

    dynamodb_table = "terraform-aws-locks"
    encrypt = true
  }
}


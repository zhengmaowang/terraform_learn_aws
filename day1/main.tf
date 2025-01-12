provider  "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "example"{
ami = "ami-002aaaf5ff99b864b"
instance_type = "t2.micro"
vpc_security_group_ids = [aws_security_group.instance.id]
user_data = <<-EOF
            #!/bin/bash
            sudo apt update -y
            sudo apt install -y apache2
            sudo systemctl start apache2
            sudo systemctl enable apache2            
            sudo echo '<center><h1>This Apache Web Server is Running on an AWS EC2 Instance </h1></center>' > /var/www/html/index.html
            sudo systemctl restart apache2
            sudo ufw disable
            EOF
tags = {
 Name = "terraform-example"
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

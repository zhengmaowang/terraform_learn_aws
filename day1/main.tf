provider  "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "example"{
ami = "ami-002aaaf5ff99b864b"
instance_type = "t2.micro"
vpc_security_group_ids = [aws_security_group.instance.id]
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

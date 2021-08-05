terraform {
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 3.0"
  }
}
}


data "aws_ami" "amazon_linux2_ami" {
most_recent = true
owners = ["amazon"]

filter {
name = "image-id"
values = ["ami-0ab4d1e9cf9a1215a"]
#values = ["ami-010aff33ed5991201"]
}
}


resource "aws_security_group" "allow_webapp_traffic" {
#name        = "allow_webapp_traffic"
description = "Allow inbound traffic"

ingress {
from_port   = 80
to_port     = 80
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress {
from_port   = 22
to_port     = 22
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

egress {
from_port   = 0
to_port     = 0
protocol    = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "allow_my_webapp"
}
}

resource "aws_instance" "webapp" {
ami           = data.aws_ami.amazon_linux2_ami.id
instance_type = "t2.micro"
vpc_security_group_ids = [aws_security_group.allow_webapp_traffic.id]
  
key_name = "webapp_nvirginia"
#key_name = "linux8p1"
user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install httpd -y
            sudo service httpd start
            sudo chkconfig httpd on
            echo "<html><h1>Hello...Pravin Bangar ...!!!   Your terraform deployment And CICD PipleLine worked --v4 !!!</h1></html>" | sudo tee /var/www/html/index.html
            hostname -f >> /var/www/html/index.html
            EOF

tags = {
Name = "TF-WebServer-Pravin"
}
}


output "instance_ip" {
value = aws_instance.webapp.public_ip
}

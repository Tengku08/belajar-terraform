terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "ap-southeast-3"
}

resource "aws_security_group" "allow_tls" {
  name        = "security_allow_all"
  description = "Allow TLS inbound traffic"
  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }

}


resource "aws_instance" "day2" {
  ami                    = "ami-0af3d3d7a46fff3a1"
  instance_type          = "t3.micro"
  key_name               = "jakarta"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  tags = {
    Name = "instance-name"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      private_key = file("./jakarta.pem")
      user        = "ubuntu"
    }
    source      = "./install-docker.sh"
    destination = "install-docker.sh"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip
      private_key = file("./jakarta.pem")
      user        = "ubuntu"
    }
    inline = [
      "chmod 777 /home/ubuntu/install-docker.sh",
      "sudo /home/ubuntu/install-docker.sh",
      "sudo docker run -d -p 80:80 ikanpaus/landingpage:v4 "
    ]
  }
}

output "ip_address" {
  value = aws_instance.day2.public_ip
}
# To Fetch Latest Ubuntu 22.04 AMI

data "aws_ami" "ubuntu" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# SSH Key Pair

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "genrated" {
  key_name = "directus-generated-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Security Group

resource "aws_security_group" "directus_sg" {
  name = "directus_sg"
  description = "To Allow Traffic SSH, HTTP and Directus"

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Directus"
    from_port   = 8055
    to_port     = 8055
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "directus" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = aws_key_pair.genrated.key_name
    vpc_security_group_ids = [ aws_security_group.directus_sg.id ]
    associate_public_ip_address = true

     user_data = <<-EOF
              #!/bin/bash
              set -eux

              # Update packages
              apt-get update -y

              # Install Docker
              apt-get install -y docker.io

              # Enable & start Docker
              systemctl enable docker
              systemctl start docker

              # Install Docker Compose (v2)
              apt-get install -y docker-compose-plugin

              # Allow ubuntu user to run docker
              usermod -aG docker ubuntu
              EOF

}

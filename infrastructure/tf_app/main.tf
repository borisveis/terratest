locals {
  remote_app_path = "/home/ubuntu/app"
}

variable "local_app_path" {
  type        = string
  description = "Local path to the FastAPI app directory (on your machine)"
}

variable "private_key_path" {
  type        = string
  description = "Path to the private key file"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  type = string
}

variable "key_name" {
  type    = string
  default = "no_key"
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "subnet_id" {
  type = string
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "fastapi_sg" {
  name        = "fastapi_sg"
  description = "Allow HTTP, HTTPS, and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
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

resource "aws_instance" "application" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.fastapi_sg.id]
  associate_public_ip_address = var.associate_public_ip_address
  depends_on                  = [aws_security_group.fastapi_sg]

  provisioner "file" {
    source      = var.local_app_path
    destination = local.remote_app_path

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

 provisioner "remote-exec" {
  inline = [
    "sudo apt update",
    "sudo apt install -y python3-pip",
    "mkdir -p ${local.remote_app_path}",
    "pip3 install --user -r ${local.remote_app_path}/requirements.txt",
    "cd ${local.remote_app_path}",
    "nohup /home/ubuntu/.local/bin/uvicorn app:app --host 0.0.0.0 --port 8000 > app.log 2>&1 &",
    "sleep 5"
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }
}

  tags = {
    Name = "fastapi-app"
  }
}

output "app_public_ip" {
  value = aws_instance.application.public_ip
}

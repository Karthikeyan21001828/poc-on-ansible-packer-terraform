terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_security_group" "docker_sg" {
  name        = "docker-sg"
  description = "Security group for EC2 instance with Docker"
 
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
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
    from_port   = 2375
    to_port     = 2375
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
}

resource "aws_instance" "docker_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  security_groups = [aws_security_group.docker_sg.name]
   
   
  provisioner "remote-exec" {
    inline = [
      # Stop Docker service to apply changes
      "sudo systemctl stop docker",

      # Create or edit Docker service configuration
      "sudo usermod -aG docker ec2-user",
      "sudo mkdir -p /etc/systemd/system/docker.service.d",
      "echo '[Service]' | sudo tee /etc/systemd/system/docker.service.d/override.conf",
      "echo 'ExecStart=' | sudo tee -a /etc/systemd/system/docker.service.d/override.conf",
      "echo 'ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock' | sudo tee -a /etc/systemd/system/docker.service.d/override.conf",

      # Reload daemon and restart Docker
      "sudo systemctl daemon-reload",
      "sudo systemctl start docker",

      # Wait for Docker to start and ensure it's listening on the correct port
      "sleep 10",
      "sudo systemctl status docker",
      "sudo mkdir -p /var/shared_data",
      "sudo chown -R 1000:1000 /var/shared_data",
      "sudo chmod -R 777 /var/shared_data",
      "sudo docker volume create shared_volume"
    ]


  connection {
    type        = "ssh"
    user        = "ec2-user" # or "ubuntu" depending on your AMI
    private_key = file(var.private_key_path) # Path to your private key file
    host        = self.public_ip  # Use the public IP of the instance
  }
}
  tags = {
    Name = "docker-instance"
  }
}


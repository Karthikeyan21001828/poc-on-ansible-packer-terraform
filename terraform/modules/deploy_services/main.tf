terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.0"
    }
  }

  required_version = ">= 0.12"
}

provider "docker" {
  host = "tcp://${var.public_host_ip}:2375"  # Ensure Docker is running
}

resource "docker_volume" "shared_volume" {
  name = "shared_volume"
}

# Jenkins Image and Container
resource "docker_image" "jenkins" {
  name = "jenkins/jenkins:lts"
}

resource "docker_container" "jenkins" {
  image = docker_image.jenkins.name
  name  = "jenkins"

  ports {
    internal = 8080
    external = 8080
  }

  env = [
    "JENKINS_OPTS=--httpPort=8080"
  ]

  restart = "unless-stopped"
  
  volumes {
    host_path      = "/var/shared_data"
    container_path = "/var/jenkins_home/deploy"
  }
}

# SonarQube Image and Container
resource "docker_image" "sonarqube" {
  name = "sonarqube"
}

resource "docker_container" "sonarqube" {
  image = docker_image.sonarqube.name
  name  = "sonarqube"

  ports {
    internal = 9000
    external = 9000
  }
}

# Apache2 Image and Container
resource "docker_image" "apache" {
  name = "httpd:latest"
}

resource "docker_container" "apache" {
  image = docker_image.apache.name
  name  = "apache"

  ports {
    internal = 80
    external = 80
  }

  volumes {
    host_path      = "/var/shared_data"
    container_path = "/usr/local/apache2/htdocs/"
  }
}

# Null Resource for Ansible Run
resource "null_resource" "ansible_run" {
  depends_on = [
    docker_container.jenkins,
    docker_container.sonarqube,
    docker_container.apache
  ]
  
  provisioner "local-exec" {
    command = <<EOT
      echo "[all]" > ../ansible-config/inventory.ini
      echo "${var.public_host_ip} ansible_user=ec2-user" >> ../ansible-config/inventory.ini
      ansible-playbook -i ../ansible-config/inventory.ini ../ansible-config/installation-playbook.yml --private-key ../ansible-config/Devkeyrg.pem
    EOT
  }
}

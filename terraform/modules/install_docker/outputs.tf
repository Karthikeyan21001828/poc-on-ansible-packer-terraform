output "docker_instance_public_ip" {
  value = aws_instance.docker_instance.public_ip
}

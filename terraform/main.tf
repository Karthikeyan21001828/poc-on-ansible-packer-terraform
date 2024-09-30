resource "null_resource" "build_ami" {
  provisioner "local-exec" {
    command = "packer build ../custom-ami/ami.json"
  }

  triggers = {
    build_time = timestamp()
  }
}

data "aws_ami" "packer_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["custom-amazon-linux-ami-with-docker-git-*"]
  }

  
}

module "install_docker" {
  source      = "./modules/install_docker"
  ami_id = data.aws_ami.packer_ami.id

}

module "deploy_services" {
  source = "./modules/deploy_services"
  public_host_ip=module.install_docker.docker_instance_public_ip
}


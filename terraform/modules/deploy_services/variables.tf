variable "ami_id" {
  description = "The AMI ID to use for the instance."
  default     = "ami-008e74dfefd9a0138"
  type        = string
}

variable "instance_type" {
  description = "The type of the instance."
  default     = "t2.medium"
  type        = string
}

variable "key_name" {
  description = "The key name for SSH access."
  default     = "Devkeyrg"
  type        = string
}
variable "region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
  type        = string  
}
variable "public_host_ip" {
  description = "The public IP address of the Docker host"
  type        = string
}

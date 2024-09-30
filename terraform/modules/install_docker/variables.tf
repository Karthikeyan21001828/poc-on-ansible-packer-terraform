variable "ami_id" {
  description = "The AMI ID to use for the instance."
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
variable "private_key_path" {
  description = "Path to the private key for SSH access to the instance"
  default     = "/home/karthikeyan/terraform/Devkeyrg.pem" 
  type        = string
}

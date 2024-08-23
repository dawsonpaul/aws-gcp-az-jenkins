variable "region" {
  default = "eu-west-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-0b87a5e6b1e8f7da9" # Ubuntu 20.04 LTS, change as needed
}

variable "key_name" {
  description = "Name of the SSH key pair"
  default = "my-key"
}

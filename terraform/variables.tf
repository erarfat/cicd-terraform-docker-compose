variable "aws_region"{
    description = "Region For Deployment"
    type = string
    default = "us-east-1"
}

variable "instance_type" {
  description = "Ec2 Instance Type"
  type = string
  default = "t3.micro"
}

variable "instance_name" {
  description = "Tag For Ec2"
  type = string
  default = "directus-server"
}
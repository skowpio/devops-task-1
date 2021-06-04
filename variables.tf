variable "region" {
  type        = string
  description = "Region to deploy into e.g: us-east-1"
}

variable "azs_count" {
  type  = string
  default = 2
}

variable "name" {
  type = string
}

variable "stage" {
  type = string
}

variable "aws_access_key" {
  type = string
  sensitive   = true
}

variable "aws_secret_key" {
  type = string
  sensitive   = true
}

variable "primary_cidr" {
  type = string
}

variable "public_subnets" {
  type = list(string)
  default = []
}

variable "private_subnets" {
  type = list(string)
  default = []
}

variable "key_pair" {
  type = string
  default = "xapo-interview"
}

variable "instance_type" {
  type = string
  default = "t3a.micro"
}

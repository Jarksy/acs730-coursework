variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "acs730-a2"
}

variable "project_tag" {
  type    = string
  default = "acs730-assignment2"
}

variable "role_tag" {
  type    = string
  default = "a2-web"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "ami_id" {
  type    = string
  default = ""
}

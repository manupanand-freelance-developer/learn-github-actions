
resource "aws_vpc" "main" {
  cidr_block = var.cidr
  tags = {
    Name="${var.env}-vpc"
  }
}
terraform {
  backend "s3" {
    bucket = "dev-ops-state-manupa"
    key    = "vpc/terraform.tfstate"
    region = "ap-south-1"
  }
}
variable "cidr" {
  default = "10.0.0.0/16"
}
variable "env" {
  default = "dev"
}
provider "aws" {
   region = "ap-south-2"
}
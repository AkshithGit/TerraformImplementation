variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "amis" {
    description = "AMIs by region"
    default = {
        us-east-1 = "ami-07ca83a2408ecb800" # Amazon linux
}
}
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "IGW_name" {}
variable "key_name" {}
variable Main_Routing_Table {}
variable "cidrs" {
  description = "IP ranges for subnets"
  type = list
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}
variable "azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type = list
  default =["us-east-1a", "us-east-1b", "us-east-1c"]
}
variable "environment" { default = "dev" }
variable "instance_type" {
  default = {
    dev = "t2.nano"
    test = "t2.micro"
    }
}


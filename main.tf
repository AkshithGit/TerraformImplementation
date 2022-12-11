
provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}


resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags = {
        Name = "${var.vpc_name}"
	Owner = "Akshith"
	environment = "${var.environment}"
    }
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
	tags = {
        Name = "${var.IGW_name}"
    }
}

resource "aws_subnet" "Public-Subnets" {
    count = 3 #0,1,2
    vpc_id = "${aws_vpc.default.id}"
    cidr_block = "${element(var.cidrs, count.index)}"
    availability_zone = "${element(var.azs, count.index)}"

    tags = {
        Name = "Public-Subnet-${count.index + 1}"
    }
}




resource "aws_route_table" "terraform-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags = {
        Name = "${var.Main_Routing_Table}"
    }
}

resource "aws_route_table_association" "terraform-public" {
    count = 3 
    subnet_id = "${aws_subnet.Public-Subnets[count.index].id}"
    route_table_id = "${aws_route_table.terraform-public.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

 resource "aws_instance" "WEB" {
     count = 2
     ami = "ami-0bd262d791ff5d074"
     availability_zone = "${element(var.azs, count.index)}"
     instance_type = "t2.micro"
     key_name = "DeekshithProject"
     subnet_id = "${aws_subnet.Public-Subnets[count.index].id}"
     vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
     associate_public_ip_address = true	
     tags = {
         Name = "Web-Server-${count.index + 1}"
         Env = "Prod"
         Owner = "Deekshith"
     }
 }




 # Creating the autoscaling launch configuration that contains AWS EC2 instance details
resource "aws_launch_configuration" "aws_autoscale_conf" {
# Defining the name of the Autoscaling launch configuration
  name          = "DeekshithConfig"
# Defining the image ID of AWS EC2 instance
  image_id      = ""
# Defining the instance type of the AWS EC2 instance
  instance_type = "t2.micro"
# Defining the Key that will be used to access the AWS EC2 instance
  key_name = "DeekshithProject"
}



# Creating the autoscaling group within us-east-1a availability zone
resource "aws_autoscaling_group" "mygroup" {
# Defining the availability Zone in which AWS EC2 instance will be launched
  availability_zones        = ["us-east-1a"]
# Specifying the name of the autoscaling group
  name                      = "autoscalegroup"
# Defining the maximum number of AWS EC2 instances while scaling
  max_size                  = 2
# Defining the minimum number of AWS EC2 instances while scaling
  min_size                  = 1
# Grace period is the time after which AWS EC2 instance comes into service before checking health.
  health_check_grace_period = 30
# The Autoscaling will happen based on health of AWS EC2 instance defined in AWS CLoudwatch Alarm 
  health_check_type         = "ELB"
# force_delete deletes the Auto Scaling Group without waiting for all instances in the pool to terminate
  force_delete              = true
# Defining the termination policy where the oldest instance will be replaced first 
  termination_policies      = ["OldestInstance"]
# Scaling group is dependent on autoscaling launch configuration because of AWS EC2 instance configurations
  launch_configuration      = aws_launch_configuration.aws_autoscale_conf.name
}



 

##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {} # corresponds to the key pair that is in AWS
variable "key_name" {}         # refers to key pair that exists in AWS so that we can SSH into the instance once its created
variable "region" {
  default = "us-east-2" # default value for this variable
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

##################################################################################
# DATA
##################################################################################

# pulling data from the provider
# here we want to use Amazon Linux (AMI) for our EC2 instance
# we want to get the AMI ID that corresponds to the most recent version on 
# Amazon linux in this region

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


##################################################################################
# RESOURCES
##################################################################################

# This makes use of the default VPC within our region.
# It is not altering the VPC but does allow terraform to interact with that
# default VPC without creating an additional one.
resource "aws_default_vpc" "default" {

}

# aws security group allows us to connect via ssh to our instance
# which will be running nginx and we also open up port 80 so that
# we can get to the web server that's going to be running on this instance
resource "aws_security_group" "allow_ssh" {
  name        = "nginx_demo"
  description = "Allow ports for nginx demo"
  vpc_id      = aws_default_vpc.default.id

  # two ingress rules to allow port 22 and 80 from outside
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # one egress rule to allow traffic from instance to the internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# defining our actual instance
resource "aws_instance" "nginx" {
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  key_name               = var.key_name # letting it know where the key pair for this EC2 instance is comming from 
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # because we want to ssh into the resource we have to define a connection block
  connection {
    type = "ssh"
    # ip on which terraform should try to connect
    # self refers to the resource beign defined
    # this corresponds to the public ip address this EC2 instace will get
    # this is how terraform knows which address to use to connect to this instance
    host        = self.public_ip
    user        = "ec2-user" # username for the ssh connection
    private_key = file(var.private_key_path)
    # location of private key which we will use for this ssh connection
    # file function reads the contents of a file
    # we're giving it a variable that contains the private key path
    # file func will read the contents of that private key file 
    # and submit that as part of the connection info
  }

  # with this conenction we want to run a provisioner
  # we want to remotely execute something so we run a provisoner called "remote-exec"
  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################

# what we want tf to output to us when the config has been instantiated
output "aws_instance_public_dns" {
  value = aws_instance.nginx.public_dns
  # value in this instance corresponds to the public DNS property of the Nginx that we created
}

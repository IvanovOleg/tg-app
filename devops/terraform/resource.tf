data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "developer" {
  key_name   = "developer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAyCCC/Z22eE++8HXUPeeYyXgWMkKOk96NnD8U3lqUwuAeX0XGqROgr3rhfBdsKr3aNAlTiybrpSZdVLIcce5FD8PqwYBc4UFSSgeq9sFhW+joZWAGb2ozHzXCLz+QTWpCxUKIM64XVHvAHVnPJucZHX5vuMvp4O74BwJaG5k1G1SYyBTklFs8nceWeKhKmo55Fy0tnu/X1P3lIM0sT8WdoH50RVxBy+5/1xTtljOAP3GYYPkCUwacoWcP7z2qWH3pRAqeAlSWSrY5U+wAxi2tv63TUYtgWiXnAKK4yVFv4p+SZ8ArQf64OK6UFfow33Mkn0sgbByKk3Y6C6X+qNoRcQ== rsa-key-20201229"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from Anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WSGI from Anywhere"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh"
  }
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.default.id
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.main.id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.allow_ssh.id]
  user_data                   = file("install.sh")
  key_name = aws_key_pair.developer.key_name

  tags = {
    Name = "HelloWorld"
  }
}

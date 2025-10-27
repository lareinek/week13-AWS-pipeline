//This is the code for vpc 

resource "aws_vpc" "my-vpc" {
  cidr_block           = "172.120.0.0/16" // class B 65k
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name       = "pipeline-Vpc"
  }
}

// internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "pipeline-IGW"
  }
}

// public subnet creation

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "172.120.1.0/24" // class c  254 ips 
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "pipeline-public-sub1"
  }
}
resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.my-vpc.id
  cidr_block              = "172.120.2.0/24" // class c  254 ips 
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "pipeline-public-sub2"
  }
  depends_on = [aws_vpc.my-vpc] # dependancy 
}

// subnet creation private
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "172.120.3.0/24" // class c  254 ips 
  availability_zone = "us-east-1a"

  tags = {
    Name = "pipeline-private-sub1"
  }
}
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = "172.120.4.0/24" // class c  254 ips 
  availability_zone = "us-east-1b"

  tags = {
    Name = "pipeline-private-sub2"
  }
}

// route table public 
resource "aws_route_table" "rtpublic" {
  vpc_id = aws_vpc.my-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

#route table association public

resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.rtpublic.id
}
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.rtpublic.id
}

// security group 

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Security group with TCP ports 80"
  vpc_id      = aws_vpc.my-vpc.id


  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-sg"
  }
}
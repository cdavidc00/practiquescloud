provider "aws" {
  region = "us-east-1"
}

# 2. VPC (VPC-03) amb el nom original perquè no s'esborri res
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VPC-03"
  }
}

# 3. Subxarxes públiques (A i B)
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet B"
  }
}

# 4. Internet Gateway i Taula de Rutes
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "VPC-03-IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# 5. Grup de Seguretat (Security Group)
resource "aws_security_group" "sg_pt22" {
  name        = "sg_pt22"
  description = "Grup de seguretat per a la practica"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6. Instàncies EC2 (ec2-a i ec2-b)
resource "aws_instance" "ec2_a" {
  ami                    = "ami-04a81a99f5ec58529"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  key_name               = "vockey"
  vpc_security_group_ids = [aws_security_group.sg_pt22.id]

  tags = {
    Name = "ec2-a"
  }
}

resource "aws_instance" "ec2_b" {
  ami                    = "ami-04a81a99f5ec58529"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_b.id
  key_name               = "vockey"
  vpc_security_group_ids = [aws_security_group.sg_pt22.id]

  tags = {
    Name = "ec2-b"
  }
}

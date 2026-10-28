terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------
# AMI de Amazon Linux 2023
# ---------------------------------------------------------------------------

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------------------------------------------------------------------------
# Mapa de instancias: 2 por cada subred (6 en total)
# ---------------------------------------------------------------------------

locals {
  instances = merge([
    for subnet_key, subnet_cidr in var.subnets : {
      for index in range(var.instances_per_subnet) :
      "${subnet_key}-${index + 1}" => {
        subnet_key  = subnet_key
        subnet_cidr = subnet_cidr
        index       = index
      }
    }
  ]...)
}

# ---------------------------------------------------------------------------
# VPC, subredes, Internet Gateway y tabla de rutas
# ---------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.project_name}-vpc"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name      = "${var.project_name}-igw"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.project_name}-subnet-${each.key}"
    Project   = var.project_name
    Subnet    = each.key
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name      = "${var.project_name}-rt-public"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.this

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Security Group y clave SSH
# ---------------------------------------------------------------------------

resource "aws_security_group" "ssh" {
  name        = "${var.project_name}-ssh"
  description = "Permite SSH desde ${var.ssh_cidr}"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    description = "Salida a Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-ssh"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/${var.project_name}-key.pem"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = {
    Name      = "${var.project_name}-key"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# Instancias EC2
# ---------------------------------------------------------------------------

resource "aws_instance" "this" {
  for_each = local.instances

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh.key_name
  subnet_id                   = aws_subnet.this[each.value.subnet_key].id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name       = "${var.project_name}-ec2-${each.key}"
    Project    = var.project_name
    Subnet     = each.value.subnet_key
    SubnetCidr = each.value.subnet_cidr
    ManagedBy  = "Terraform"
  }

  depends_on = [aws_route_table_association.public]
}

# ---------------------------------------------------------------------------
# Salidas
# ---------------------------------------------------------------------------

output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR de la VPC"
  value       = aws_vpc.this.cidr_block
}

output "availability_zone" {
  description = "Zona de disponibilidad utilizada"
  value       = var.availability_zone
}

output "subnet_ids" {
  description = "IDs de las subredes por clave"
  value       = { for key, subnet in aws_subnet.this : key => subnet.id }
}

output "subnet_cidrs" {
  description = "CIDR de cada subred"
  value       = { for key, subnet in aws_subnet.this : key => subnet.cidr_block }
}

output "instance_ids" {
  description = "IDs de las 6 instancias EC2"
  value       = { for key, instance in aws_instance.this : key => instance.id }
}

output "public_ips" {
  description = "IPs públicas de las 6 instancias"
  value       = { for key, instance in aws_instance.this : key => instance.public_ip }
}

output "private_key_path" {
  description = "Ruta local de la clave privada generada"
  value       = local_sensitive_file.private_key.filename
}

output "ssh_commands" {
  description = "Comandos SSH listos para copiar"
  value = {
    for key, instance in aws_instance.this :
    key => "ssh -i ${local_sensitive_file.private_key.filename} ec2-user@${instance.public_ip}"
  }
}

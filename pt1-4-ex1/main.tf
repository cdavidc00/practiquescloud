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
# Variables
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "Región de AWS donde se despliegan las instancias"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo utilizado para nombrar y etiquetar los recursos"
  type        = string
  default     = "pt1-4-ex1"
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Número de instancias EC2 que se crean"
  type        = number
  default     = 2

  validation {
    condition     = var.instance_count == 2
    error_message = "El ejercicio requiere exactamente 2 instancias EC2."
  }
}

variable "ssh_cidr" {
  description = "CIDR autorizado para conectarse por SSH (recomendado: IP pública /32)"
  type        = string
  default     = "92.189.204.83/32"
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
# VPC por defecto
# ---------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

# ---------------------------------------------------------------------------
# Clave SSH
# ---------------------------------------------------------------------------

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
# Security Group: solo SSH desde la IP autorizada
# ---------------------------------------------------------------------------

resource "aws_security_group" "ssh" {
  name        = "${var.project_name}-ssh"
  description = "Permite SSH desde ${var.ssh_cidr}"
  vpc_id      = data.aws_vpc.default.id

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

# ---------------------------------------------------------------------------
# Instancias EC2
# ---------------------------------------------------------------------------

resource "aws_instance" "web" {
  count = var.instance_count

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh.key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name      = "${var.project_name}-web-${count.index + 1}"
    Project   = var.project_name
    ManagedBy = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# Salidas
# ---------------------------------------------------------------------------

output "ami_id" {
  description = "AMI de Amazon Linux 2023 utilizada"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "instance_ids" {
  description = "IDs de las instancias EC2"
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "IPs públicas de las instancias"
  value       = aws_instance.web[*].public_ip
}

output "public_dns" {
  description = "DNS públicos de las instancias"
  value       = aws_instance.web[*].public_dns
}

output "private_key_path" {
  description = "Ruta local de la clave privada generada"
  value       = local_sensitive_file.private_key.filename
}

output "ssh_commands" {
  description = "Comandos SSH listos para copiar"
  value = [
    for instance in aws_instance.web :
    "ssh -i ${local_sensitive_file.private_key.filename} ec2-user@${instance.public_ip}"
  ]
}

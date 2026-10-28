variable "aws_region" {
  description = "Región de AWS donde se despliega la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo utilizado para nombrar y etiquetar los recursos"
  type        = string
  default     = "pt1-4-ex2"
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone" {
  description = "Zona de disponibilidad común a las tres subredes"
  type        = string
  default     = "us-east-1a"
}

variable "subnets" {
  description = "Mapa de subredes: clave lógica -> CIDR"
  type        = map(string)
  default = {
    A = "10.0.32.0/25"
    B = "10.0.30.0/23"
    C = "10.0.33.0/28"
  }
}

variable "instance_type" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "instances_per_subnet" {
  description = "Número de instancias EC2 por subred"
  type        = number
  default     = 2

  validation {
    condition     = var.instances_per_subnet == 2
    error_message = "El ejercicio requiere exactamente 2 instancias por subred."
  }
}

variable "ssh_cidr" {
  description = "CIDR autorizado para conectarse por SSH (recomendado: IP pública /32)"
  type        = string
  default     = "92.189.204.83/32"
}

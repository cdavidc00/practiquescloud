# Prácticas Cloud — Pt1.4

Repositorio de prácticas del módulo **OPT Cloud Computing** del ciclo **ASIX2**, curso **2026-2027**.

## Autor

- **Alumno:** David Bautista
- **Módulo:** OPT Cloud Computing
- **Grupo:** ASIX2
- **Práctica:** Pt1.4

## Ejercicios

| Ejercicio | Contenido | Documentación |
| --- | --- | --- |
| **Ejercicio 1** | 2 instancias EC2 `t3.micro` con Amazon Linux 2023 desplegadas con Terraform en `us-east-1`. | [pt1-4-ex1/README.md](pt1-4-ex1/README.md) |
| **Ejercicio 2** | VPC `10.0.0.0/16`, 3 subredes en `us-east-1a` y 6 instancias EC2 (`t3.micro`) desplegadas con Terraform. Incluye el procedimiento equivalente en la consola de AWS. | [pt1-4-ex2/README.md](pt1-4-ex2/README.md) |

## Estructura del repositorio

```text
practiquescloud/
├── .gitignore
├── README.md
├── pt1-4-ex1/
│   ├── assets/
│   │   ├── topologia.png
│   │   └── topologia.drawio
│   ├── main.tf
│   └── README.md
└── pt1-4-ex2/
    ├── assets/
    │   ├── topologia.png
    │   ├── topologia.drawio
    │   ├── vpc.png
    │   ├── subnets.png
    │   ├── vpc_subnets.png
    │   └── ec2_instances.png
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    └── README.md
```

## Requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.5`
- Credenciales de AWS con permisos para crear recursos de **EC2**, **VPC**, **Security Groups** y **Key Pairs**
- Región utilizada: `us-east-1`
- Sistema operativo de las instancias: **Amazon Linux 2023**

## Puesta en marcha rápida

Cada ejercicio es independiente y se despliega desde su propia carpeta:

```bash
cd pt1-4-ex1
terraform init
terraform plan
terraform apply
```

```bash
cd pt1-4-ex2
terraform init
terraform plan
terraform apply
```

Para eliminar los recursos y evitar costes:

```bash
terraform destroy
```

## Despliegue y validación (28/10/2026)

Ambos ejercicios se desplegaron realmente en AWS (cuenta AWS Academy `7678-3940-2707`, región `us-east-1`):

- **Ejercicio 1:** 2 instancias `t3.micro` en estado `running`.
- **Ejercicio 2:** VPC `10.0.0.0/16`, 3 subredes en `us-east-1a` y 6 instancias `t3.micro` en `running`; las capturas reales de la consola están en `pt1-4-ex2/assets/`.
- Al finalizar las comprobaciones se ejecutó `terraform destroy` en ambos ejercicios para no consumir crédito del laboratorio.

## Seguridad

- Las credenciales de AWS **no** se almacenan en el repositorio.
- Los archivos de estado (`terraform.tfstate`), el directorio `.terraform/` y las claves privadas (`*.pem`) están excluidos mediante `.gitignore`.
- El acceso SSH se limita a la IP indicada en la variable `ssh_cidr`.
- No se deben subir claves privadas, tokens de sesión ni el contenido de `~/.aws/credentials`.

## Notas

- Las capturas de la consola de AWS correspondientes a la Parte B del Ejercicio 2 se encuentran en `pt1-4-ex2/assets/`.
- Los diagramas se han realizado con la iconografía oficial de AWS y se incluyen tanto en formato PNG como en su archivo editable de draw.io.

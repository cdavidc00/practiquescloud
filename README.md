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



# Pt2.2 – Infraestructura bàsica a AWS amb Terraform

**Alumne:** David Bautista
**Grup:** ASIX2 – Mòdul OPT: Cloud Computing

## 1. Descripció

Infraestructura a AWS (regió `us-east-1`) desplegada amb Terraform:

- VPC `VPC-03` (10.0.0.0/16)
- Public Subnet A (10.0.1.0/24, us-east-1a) i Public Subnet B (10.0.2.0/24, us-east-1b), amb IP pública automàtica
- Internet Gateway i taula de rutes pública (0.0.0.0/0 → IGW) associada a les dues subxarxes
- Security Group: SSH des de qualsevol lloc, ICMP només des de la VPC, tot el trànsit sortint permès
- 2 instàncies EC2 `t3.micro` (Amazon Linux 2023), `ec2-a` i `ec2-b`, amb la clau `vockey`

## 2. Diagrama

![Diagrama](assets/diagrama.png)

## 3. Explicació del codi (`main.tf`)

_Explica amb les teves paraules cada bloc: provider, VPC, subnets, IGW, route table, security group, instàncies._

## 4. Desplegament

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

![terraform apply](assets/terraform-apply.png)

## 5. Comprovacions

### VPC
![VPC](assets/vpc.png)

### Subxarxes
![Subxarxes](assets/subnets.png)

### Internet Gateway i taula de rutes
![IGW](assets/igw.png)
![Route table](assets/route-table.png)

### Security Group
![Security group](assets/security-group.png)

### Instàncies EC2
![EC2](assets/ec2.png)

### Prova de connectivitat

Connexió SSH a `ec2-a` i ping a la IP privada d'`ec2-b`:

```bash
ssh -i labsuser.pem ec2-user@<IP_PUBLICA_EC2_A>
ping <IP_PRIVADA_EC2_B>
```

![Ping](assets/ping.png)

## 6. Destrucció dels recursos

```bash
terraform destroy
```

![terraform destroy](assets/terraform-destroy.png)

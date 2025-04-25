# n8n AWS Terraform Quick Start Guide

This guide makes it easy for new developers to deploy n8n on AWS using Terraform. It explains each step, the role of every file, and how to use the included scripts for a secure, production-ready setup.

---

## What Does This Deploy?
Terraform will automatically set up:
- **VPC, Subnets, Routing:** Secure network isolation with public/private subnets, NAT, and all routing handled for you.
- **EC2 Instance:** Runs n8n in Docker, using an EBS volume for persistent data.
- **RDS PostgreSQL:** Managed database for workflows and credentials.
- **(Optional) Redis (ElastiCache):** For n8n queue mode and scaling.
- **(Optional) Application Load Balancer (ALB) & ACM:** For HTTPS and scaling.
- **Route53 DNS:** Custom subdomain for your n8n instance.
- **Security Groups:** Strict firewall rules, with SSH access restricted to your IP.
- **Budget & Monitoring:** AWS Budgets and CloudWatch alarms for cost control.

No need to manually manage subnet IDs, CIDRs, or SSH rules—everything is automated!

---

## Folder & File Overview
```
n8n-aws-terraform/
├── main.tf                # Orchestrates resources (docs only)
├── variables.tf           # All config options (edit this first!)
├── terraform.tfvars       # Your secrets/values (never commit this)
├── outputs.tf             # Shows connection info after apply
├── provider.tf            # AWS provider config
├── vpc.tf                 # Networking (VPC, subnets, NAT)
├── ec2.tf                 # EC2 instance, EBS volume
├── rds.tf                 # RDS Postgres
├── security_groups.tf     # All firewall rules
├── load_balancer.tf       # ALB, ACM, SSL (optional)
├── route53.tf             # DNS records
├── budget_monitoring.tf   # Budgets & CloudWatch
├── locals.tf              # Internal networking logic (no user edits)
├── scripts/
│   ├── user_data.sh       # EC2 bootstrap: installs Docker, runs n8n
│   └── set_n8n_env.sh     # Helper to set env vars for manual use
└── README.md              # This file
```

---

## Step-by-Step Setup

### 1. Prerequisites
- AWS Account ([sign up](https://aws.amazon.com/))
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Domain managed in Route53 (for HTTPS and custom DNS)

### 2. Configure AWS Credentials
```sh
aws configure
```
Enter your AWS Access Key, Secret Key, region (e.g., `us-east-1`), and output format (`json`).

### 3. Edit Variables
- Open `variables.tf` for descriptions and guidance on each variable.
- Place your actual values (passwords, subdomain, etc.) in `terraform.tfvars`.
  - **Never commit secrets!**
- Key variables:
  - `route53_zone_name`: Your domain (e.g., `example.com`)
  - `n8n_subdomain`: Subdomain for n8n (default: `n8n`)
  - `azs`: At least two availability zones for high availability
  - `acm_certificate_arn`: (Optional) Use your own ACM cert, or let Terraform create one

### 4. Initialize Terraform
```sh
terraform init
```

### 5. Review the Plan
```sh
terraform plan
```
See what will be created/changed.

### 6. Apply the Configuration
```sh
terraform apply
```
Type `yes` when prompted. This provisions all AWS resources.

### 7. Check the Outputs
After apply, Terraform will show:
- EC2 public IP and DNS
- RDS endpoint
- DNS record (e.g., `n8n.example.com`)

### 8. Access Your n8n Instance
- Wait a few minutes for AWS to finish provisioning.
- Visit your custom domain (e.g., `https://n8n.example.com`).
- Log in and start building workflows!

---

## How Each Terraform File Works
- **main.tf**: Documentation only; all resources are auto-included.
- **provider.tf**: Configures AWS provider and region.
- **variables.tf**: All user-editable settings (with inline help). VPC and subnet IDs/CIDRs are automated unless using advanced networking.
- **terraform.tfvars**: Your secrets and values. **Never commit this file!**
- **scripts/user_data.sh**: EC2 bootstrap script. Installs Docker and runs n8n with best practices (persistent EBS data, env vars, HTTPS, etc.).
- **scripts/set_n8n_env.sh**: Helper for manual setup or troubleshooting—exports all required environment variables and shows example DB commands.
- **outputs.tf**: Shows connection info after deployment.
- **locals.tf**: Internal logic for networking. No user edits needed.

---

## Environment Variables & Scripts
- The EC2 instance uses environment variables for database and n8n configuration. These are set automatically by Terraform and passed to Docker in `user_data.sh`.
- To manually set up or troubleshoot, SSH into the EC2 instance and use `scripts/set_n8n_env.sh`.
- Example environment variables (see `set_n8n_env.sh`):
  - `DB_TYPE`, `DB_POSTGRESDB_HOST`, `DB_POSTGRESDB_USER`, `DB_POSTGRESDB_PASSWORD`, `n8n_host`, `WEBHOOK_URL`, etc.

---

## Outputs
After `terraform apply`, look for:
- EC2 public IP and DNS
- RDS endpoint
- DNS record (use this in your browser)

---

## Security & Best Practices
- **Never commit secrets to version control.**
- SSH access is restricted to the IP running `terraform apply`.
- Use IAM roles and least-privilege access.
- Enable budget alerts to avoid surprise bills.
- EBS volume is encrypted by default.
- Review security group rules and adjust as needed.

---

## Troubleshooting & Customization
- All networking and most variables are automated. Only advanced users need to customize VPC/subnet IDs.
- To destroy all resources, run:
  ```sh
  terraform destroy
  ```
- For local dev, use `../n8n-aws-docker/` with Docker Compose.
- For manual EC2 setup, see scripts in `../n8n-aws-bash/`.

---

## Need Help?
- See comments in each `.tf` file for details.
- Official [Terraform docs](https://www.terraform.io/docs/)
- Official [AWS docs](https://docs.aws.amazon.com/)

---

Happy automating with n8n on AWS!

## Step-by-Step Guide for Beginners

### 1. Prerequisites
- **AWS Account**: [Sign up here](https://aws.amazon.com/)
- **Terraform**: [Install instructions](https://www.terraform.io/downloads.html)
- **AWS CLI**: [Install instructions](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- **Domain Name**: Registered in AWS Route53 (or transfer/manage your domain in Route53)

### 2. AWS Credentials
Set up your AWS credentials so Terraform can create resources:
```sh
aws configure
```
Enter your AWS Access Key, Secret Key, region (e.g., `us-east-1`), and output format (`json`).

### 3. Configure Variables
- Edit `variables.tf` for descriptions and guidance on each variable.
- Place your actual values in `terraform.tfvars` (never commit secrets!).
- Key variables:
  - `route53_zone_name`: Your domain (e.g., `example.com`)
  - `n8n_subdomain`: Subdomain for N8N (default: `n8n`)
  - `azs`: Must have at least two elements for HA setup. **You do _not_ need to supply subnet IDs, subnet CIDRs, or ssh_access_cidr—these are created and managed automatically. SSH access is restricted to the IP running terraform apply.**
  - `acm_certificate_arn`: (Optional) If you want to use your own ACM cert, otherwise Terraform will create one for you.
- See comments in `terraform.tfvars` for how to get AMI IDs, ACM ARNs, etc.
- **Note:** All VPC and subnet IDs are now managed internally using `locals.tf`. Only provide these if using existing infrastructure.

### 4. Initialize Terraform
This downloads required plugins and sets up your working directory:
```sh
terraform init
```

### 5. Review the Plan
See what Terraform will create/modify:
```sh
terraform plan
```

### 6. Apply the Configuration
This will create all AWS resources. Type `yes` when prompted:
```sh
terraform apply
```

### 7. Check the Outputs
After apply, Terraform will show:
- EC2 public IP and DNS
- RDS endpoint
- DNS record (e.g., `n8n.example.com`)

### 8. Access Your N8N Instance
- Wait a few minutes for AWS to finish provisioning.
- Visit your custom domain (e.g., `https://n8n.example.com`).
- Log in and start building workflows!

---

## How Each Terraform File Works
- **main.tf**: Documentation only. All resources are auto-included by Terraform.
- **provider.tf**: Configures AWS provider and region.
- **variables.tf**: All user-editable settings (with inline help). Edit this file for guidance. VPC and subnet IDs and CIDRs are now managed automatically and do not require user input unless using existing infrastructure or advanced networking. SSH access is now automatically restricted to the public IP running terraform apply.
- **terraform.tfvars**: User secrets and actual values. **Do not commit secrets!**
- **scripts/user_data.sh**: EC2 bootstrap script. Edit to customize Docker/n8n setup.
- **.gitignore**: Prevents leaking of state, secrets, and scripts.
- **vpc.tf**: Creates your network, subnets, NAT, and routing. All IDs and subnet CIDRs are output and referenced internally via `locals.tf`.
- **security_groups.tf**: Defines firewall rules for EC2, RDS, Redis, ALB.
- **ec2.tf**: Provisions the server that runs N8N (with Docker and EBS volume).
- **rds.tf**: Creates managed PostgreSQL (with security, backups, encryption).
- **redis.tf**: (Optional) Adds Redis for N8N queue mode.
- **load_balancer.tf**: (Optional) Sets up ALB, SSL, and health checks.
- **route53.tf**: Creates DNS records for your subdomain.
- **budget_monitoring.tf**: Sets up budget alerts and CloudWatch monitoring.
- **locals.tf**: Provides VPC and subnet IDs and CIDRs for all resources automatically. No user input required for these unless overriding for advanced networking.
- **outputs.tf**: Shows useful info after deployment.

---

## Common Questions & Troubleshooting
- **Do I need to manually run each .tf file?**
  - No! Terraform reads all .tf files in the folder automatically.
- **How do I destroy everything?**
  - Run `terraform destroy` (be careful: this deletes all resources!)
- **How do I update settings?**
  - Edit `variables.tf`, then run `terraform apply` again.
- **Where do I set secrets/passwords?**
  - In `variables.tf` or via environment variables (`TF_VAR_<name>`). Never commit secrets to version control.
- **How do I see costs?**
  - Budget alerts and CloudWatch alarms are included. Check your AWS Billing dashboard for details.

---

## Local Development (Optional)
You can run N8N locally using Docker Compose before deploying to AWS:
```sh
cd ../n8n-aws-docker
# Edit docker-compose.yml as needed
docker-compose up --build
```
Visit [http://localhost:5678](http://localhost:5678)

---

## EC2 Bash Scripts (Advanced/Manual)
If you want to manually set up an EC2 instance:
1. SSH into your EC2 server.
2. Run `install_prerequisites.sh` to install Docker and Node.js.
3. Edit and source `setup_env.sh` to set secrets and DB info.
4. Run `run_n8n.sh` to start N8N.

---

## Outputs
After `terraform apply`, look for:
- EC2 public IP and DNS
- RDS endpoint
- DNS record (use this in your browser)

---

## Security & Best Practices
- Never commit secrets to version control.
- Rotate credentials regularly.
- Use IAM roles and least-privilege access.
- Enable budget alerts to avoid surprise bills.

---

## Need Help?
- Check comments in each `.tf` file for details.
- See the official [Terraform docs](https://www.terraform.io/docs/).
- For AWS help, see the [AWS docs](https://docs.aws.amazon.com/).

---

Happy automating with N8N on AWS!
- The deployment will automatically create a DNS record in your Route53 hosted zone, pointing your chosen subdomain (e.g., `n8n.example.com`) to the EC2 instance running N8N.
- You can configure the domain and subdomain via the `variables.tf` file or by passing variables to Terraform.
- The DNS record is managed in `route53.tf`.

## Local Docker Setup
A `n8n-aws-docker/` folder is provided at the project root for running N8N locally using Docker and docker-compose. This is useful for development or testing before deploying to AWS.

**Usage:**
1. Go to the `n8n-aws-docker/` directory:
   ```sh
   cd ../n8n-aws-docker
   ```
2. Build and start N8N with Docker Compose:
   ```sh
   docker-compose up --build
   ```
3. Access N8N at [http://localhost:5678](http://localhost:5678)

You can customize the Dockerfile or docker-compose.yml to add plugins, change environment variables, or mount additional volumes.

## EC2 Bash Setup Scripts
The `n8n-aws-bash/` folder contains bash scripts to help set up your EC2 instance for running N8N:

- `install_prerequisites.sh`: Installs Docker, Node.js, and required dependencies on Ubuntu EC2.
- `setup_env.sh`: Sets up environment variables for N8N and database configuration.
- `run_n8n.sh`: Runs the N8N Docker container using the configured environment variables.

**Usage:**
1. SSH into your EC2 instance.
2. Run `install_prerequisites.sh` to install Docker and Node.js.
3. Edit `setup_env.sh` to set your secrets and database connection details.
4. Source `setup_env.sh` and run `run_n8n.sh` to start N8N.

These scripts are helpful for manual setup, debugging, or customizing the EC2 user_data process beyond the default automation.

## Outputs
- The public IP and DNS of the EC2 instance will be shown after `terraform apply`.
- Use these to verify your DNS setup and access N8N via your custom domain.

## Notes
- The load balancer is optional and recommended for production. If using a load balancer, the DNS record can be pointed to the ALB instead.
- Make sure to secure your secrets and credentials.
- For SSL/TLS, consider using AWS ACM and updating the load balancer or EC2 setup accordingly.

---

Generated by AI assistant.

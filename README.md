# N8N on AWS: Complete Step-by-Step Guide

This guide walks you through deploying N8N on AWS using Terraform, Docker, and Bash scripts. It is designed for beginners in DevOps/SRE and covers everything from AWS setup to production best practices.

---

## 1. Prerequisites
- **AWS Account** (with permissions to create EC2, RDS, ALB, Route53, ElastiCache, etc.)
- **Domain Name** in Route53 (for HTTPS and custom DNS)
- **Local Machine:**
  - [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
  - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  - [Docker & Docker Compose](https://docs.docker.com/get-docker/)

---

## 1a. Check Local Prerequisites (Recommended)
Before starting, run the provided script to check your local environment:

```sh
chmod +x setup_requisites.sh
./setup_requisites.sh
```
- This script checks for AWS CLI, Terraform, Docker, Docker Compose, and AWS credentials.
- If you see a "permission denied" error, ensure you ran the `chmod +x` command above.

## 2. Configure AWS Credentials
Set up your AWS credentials so Terraform and CLI tools can access your account:
```sh
aws configure
```
Enter your AWS Access Key, Secret Key, region, and output format.

---

## 3. Deploy AWS Infrastructure with Terraform
1. Go to the Terraform folder:
   ```sh
   cd n8n-aws-terraform
   ```
2. Edit `variables.tf` to set your AWS region, VPC/subnet IDs, domain, and other variables (see comments in the file).
3. Initialize and apply the Terraform configuration:
   ```sh
   terraform init
   terraform apply
   ```
   - This will create VPC, subnets, security groups, EC2, RDS (Postgres), ALB (with HTTPS), Redis, Route53 DNS, and persistent EBS storage for N8N.
4. After apply, note the outputs: EC2 public DNS, ALB DNS, RDS endpoint, Redis endpoint, etc.

---

## 4. Prepare Your Environment Variables
- Copy the `.env` example from `n8n-aws-docker/README.md` and fill in your secrets, DB, and Redis connection details using the Terraform outputs.
- For bash-based setup, edit `n8n-aws-bash/setup_env.sh` with the same details.

---

## 5. Set Up N8N on EC2
### Option A: Use Bash Scripts (manual/SSH)
1. SSH into your EC2 instance:
   ```sh
   ssh ubuntu@<ec2-public-dns>
   ```
2. Run the scripts in `n8n-aws-bash/` in order:
   - `bash install_prerequisites.sh` (installs Docker, Node.js)
   - Edit and `source setup_env.sh` (set your secrets/DB/Redis)
   - `bash run_n8n.sh` (starts N8N in Docker)

### Option B: Use Docker Compose (for local dev or custom EC2 AMI)
1. Go to `n8n-aws-docker/` and update your `.env` file.
2. Run:
   ```sh
   docker-compose up --build -d
   ```

---

## 6. Access N8N
- Use your Route53 domain (e.g., https://n8n.example.com) or ALB DNS to access N8N in your browser.
- Login with the credentials set in your environment variables.

---

## 7. Production Best Practices
- **Database:** Uses AWS RDS PostgreSQL (managed, backed up, secure).
- **HTTPS:** All traffic goes through AWS ALB with SSL (ACM certificate required).
- **Scaling:** Redis (ElastiCache) is provisioned for n8n queue mode (see n8n docs for scaling horizontally).
- **Persistence:** N8N data is stored on an encrypted EBS volume attached to EC2. Set up EBS snapshots for backup.
- **Backups:** (Optional) Use S3 sync or EBS snapshot automation for extra redundancy.
- **Security:** All secrets are managed via environment variables and security groups restrict access.

---

## 8. Troubleshooting & Customization
- See `n8n-aws-docker/README.md` and `n8n-aws-bash/README.md` for more details.
- For advanced scaling, SSL, or monitoring, see the [official n8n docs](https://docs.n8n.io/hosting/).

---

**You now have a production-grade, scalable, and secure N8N deployment on AWS!**

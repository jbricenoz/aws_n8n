#############################################
# main.tf
# Root module for N8N AWS Terraform Deployment
# This file orchestrates the creation of the infrastructure step by step.
# Each section is clearly commented and references the respective .tf file.
#############################################

# --- 1. Provider & Backend Configuration ---
# See provider.tf for AWS provider setup and backend (state) configuration.
# (No explicit provider block here; see provider.tf)

# --- 2. VPC & Networking ---
# Sets up VPC, public/private subnets, NAT gateway, route tables, and associations.
# See vpc.tf for detailed resources.
# All subnet, AZ, and CIDR variables are defined in variables.tf.

# --- 3. Security Groups ---
# Creates security groups for ALB, EC2, RDS, and Redis.
# See security_groups.tf for rules and documentation.

# --- 4. EC2 Instance & EBS Volume ---
# Provisions the EC2 instance to run n8n in Docker with persistent storage.
# See ec2.tf for EC2, EBS, and volume attachment resources.

# --- 5. RDS PostgreSQL ---
# Provisions a managed PostgreSQL database for n8n.
# See rds.tf for DB subnet group, parameter group, and instance.

# --- 6. Redis (ElastiCache) ---
# (Optional) Adds Redis for n8n queue mode and scaling.
# See redis.tf for subnet group, cluster, and security group.

# --- 7. Load Balancer & ACM (SSL) ---
# (Optional/Recommended) Sets up ALB, target group, listeners, and ACM certificate.
# See load_balancer.tf for all resources and DNS integration.

# --- 8. Route53 DNS ---
# Creates/updates DNS records to point your domain/subdomain to n8n.
# See route53.tf for configuration and documentation.

# --- 9. Budget & Monitoring ---
# Adds AWS Budgets and CloudWatch alarms for cost control and monitoring.
# See budget_monitoring.tf for details.

# --- 10. Outputs ---
# Outputs useful info such as EC2 public IP, DNS, RDS endpoint, etc.
# See outputs.tf for all outputs.

# --- 11. Variables ---
# All input variables are defined and documented in variables.tf.

# --- Resource Inclusion ---
# All resources are included automatically by Terraform when present in the same directory.
# No explicit module or resource block is required here unless using external modules.

# --- How to Apply ---
# 1. Review and update variables in variables.tf
# 2. Run: terraform init
# 3. Run: terraform apply
# 4. Follow the outputs and documentation for next steps

# For more details, see the README.md and comments in each .tf file.

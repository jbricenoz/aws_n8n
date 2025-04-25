// variables.tf
// Input variables for customizing the deployment.

// Define variables for VPC, EC2, RDS, etc. here.

variable "route53_zone_name" {
  description = <<EOT
The domain name you own and manage in AWS Route53 (for example: monkeytrailroute.com).

How to find this in AWS:
1. Go to the AWS Console (https://console.aws.amazon.com/).
2. Search for 'Route 53' in the search bar and click on it.
3. In the left menu, click 'Hosted zones'.
4. Find your domain name in the list (e.g. monkeytrailroute.com).
5. Use that domain name as the value.
EOT
  type        = string
}
variable "n8n_subdomain" {
  description = <<EOT
The subdomain you want for your n8n instance (for example: 'n8n' to create n8n.monkeytrailroute.com).

How to choose:
- Pick a short, easy-to-remember word (like 'n8n' or 'automation').
- This will be the part before your main domain.
- If unsure, leave as 'n8n'.
EOT
  type        = string
  default     = "n8n"
}
# --- Budget and Monitoring Integration ---
variable "aws_budget_limit" {
  description = <<EOT
The maximum amount of money (in USD) you want to spend on AWS per month. This helps prevent surprise bills.

How to choose:
- If you are just testing, set this to a low value like '10'.
- If you are running production, set it to your real budget.
EOT
  type        = string
  default     = "90"
}
variable "aws_budget_threshold" {
  description = <<EOT
The percentage of your AWS budget when you want to get an alert email.

How to choose:
- 80 means you will be alerted when you use 80% of your budget.
- Leave as 80 if you are unsure.
EOT
  type        = number
  default     = 80
}
variable "budget_alert_email" {
  description = <<EOT
Your email address where AWS will send alerts about your spending or server issues.

How to choose:
- Use your main email address so you don't miss important alerts.
- You can use a team/shared email if you want multiple people to get alerts.
EOT
  type        = string
}
# --- AWS Region ---
variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "us-west-2"
}

data "aws_availability_zones" "available" {}

# --- Environment ---
variable "environment" {
  description = <<EOT
A name for this environment (for example: dev, staging, or prod).

How to choose:
- Use 'dev' for testing, 'prod' for production, or any label you want.
- This helps you organize different setups in AWS.
EOT
  type        = string
  default     = "prod"
}
# --- VPC/Subnet IDs ---
# vpc_id, public_subnet_ids, and private_subnet_ids are now provided automatically via locals. No user input required.
# --- Default Tags ---
variable "default_tags" {
  description = <<EOT
Extra labels (called tags) you want to add to all your AWS resources.

How to use:
- Tags are key-value pairs (like 'project = n8n').
- They help you organize and find your resources in AWS.
- If you don't need this, leave as-is.
EOT
  type        = map(string)
  default     = {}
}
# --- Private Subnet IDs ---
# Now provided via locals. No user input required.
# --- EC2 Availability Zone ---
# ec2_availability_zone is now auto-selected from azs[0] in resource definitions.

# --- n8n Data EBS Size ---
variable "n8n_data_ebs_size" {
  description = <<EOT
How much disk space (in GB) to give your n8n server for storing workflows and files.

How to choose:
- 20 is enough for most small or test setups.
- Increase if you expect to store lots of data.
EOT
  type        = number
  default     = 20
}
# --- n8n Data EBS Type ---
variable "n8n_data_ebs_type" {
  description = <<EOT
The type of disk to use for n8n data storage.

How to choose:
- 'gp3' is the default and works for most cases.
- Only change if you know you need a different disk type.
EOT
  type        = string
  default     = "gp3"
}
# --- DB Max Connections ---
variable "db_max_connections" {
  description = <<EOT
The maximum number of simultaneous database connections allowed.

How to choose:
- Leave at 100 unless you know you need more for a large team or heavy usage.
EOT
  type        = number
  default     = 100
}
# --- VPC CIDR ---
variable "vpc_cidr" {
  description = <<EOT
The range of IP addresses for your VPC, written like '10.0.0.0/16'.

How to find this in AWS:
1. Go to the AWS Console (https://console.aws.amazon.com/).
2. Search for 'VPC' and click on it.
3. In the left menu, click 'Your VPCs'.
4. Find your VPC and look for the 'IPv4 CIDR' column (like 10.0.0.0/16).
5. Use that value here.

Only change if you need a custom network setup.
EOT
  type        = string
  default     = "10.0.0.0/16"
}
# --- SSH Access CIDR ---
# SSH access is now restricted to the public IP running terraform apply (fetched automatically).
# --- Public Subnet IDs ---
# See above: public_subnet_ids now output from VPC module/resources if managed by Terraform.
# --- Public Subnet CIDRs ---
# public_subnet_cidrs variable removed; use outputs or data sources if needed.
# --- Private Subnet CIDRs ---
# --- Private Subnet CIDRs ---
# private_subnet_cidrs are now calculated automatically from the VPC CIDR and number of AZs. Advanced users may override by defining this variable manually.
# --- Availability Zones ---

variable "n8n_rds_db_name" {
  description = "Database name for n8n RDS Postgres instance."
  type        = string
  default     = "n8n"
}

variable "n8n_rds_username" {
  description = "Database username for n8n RDS Postgres instance."
  type        = string
  default     = "n8nadmin"
}

variable "n8n_rds_password" {
  description = "Database password for n8n RDS Postgres instance."
  type        = string
  sensitive   = true
  default     = "changeme123"
}

# azs is now defaulted to all available zones in region using data source.
# --- EC2 AMI ---
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

variable "ec2_ami" {
  description = "The AMI ID for the EC2 instance. Defaults to latest Ubuntu 22.04 LTS."
  type        = string
  default     = ""
}
# --- EC2 Instance Type ---
variable "ec2_instance_type" {
  description = "The EC2 instance type for n8n."
  type        = string
  default     = "t3.micro"
}
# --- EC2 Key Name ---
# variable "ec2_key_name" {
#   description = <<EOT
# The name of the SSH key pair to use for EC2 access.
#
# How to find this in AWS:
# 1. Go to the AWS Console (https://console.aws.amazon.com/).
# 2. Search for "EC2" and click on it.
# 3. In the left menu, click "Key Pairs".
# 4. Use an existing key pair name or create a new one.
# EOT
#   type        = string
# }
# --- ACM Certificate ARN ---
# ACM certificate is now provisioned automatically by Terraform for your subdomain.
# --- DB Identifier ---
variable "db_identifier" {
  description = <<EOT
A unique name for your RDS database instance (e.g., "n8n-db").
EOT
  type        = string
  default     = "n8n-db"
}
# --- DB Engine Version ---
variable "db_engine_version" {
  description = <<EOT
The version of PostgreSQL to use for your RDS instance.
EOT
  type        = string
  default     = "17.4"
}
# --- DB Instance Class ---
variable "db_instance_class" {
  description = "The instance type for your RDS database."
  type        = string
  default     = "db.t3.micro"
}
# --- DB Allocated Storage ---
variable "db_allocated_storage" {
  description = "Allocated storage (GB) for RDS."
  type        = number
  default     = 20
}
# --- DB Max Allocated Storage ---
variable "db_max_allocated_storage" {
  description = "Maximum allocated storage (GB) for RDS."
  type        = number
  default     = 100
}
# --- DB Name ---
variable "db_name" {
  description = "Initial database name for RDS."
  type        = string
  default     = "n8n"
}
# --- DB Username ---
variable "db_username" {
  description = "Username for your RDS database."
  type        = string
  default     = "n8nuser"
}
# --- DB Password ---
variable "db_password" {
  description = "Password for your RDS database."
  type        = string
  sensitive   = true
}
# --- DB Backup Retention ---
variable "db_backup_retention" {
  description = "Number of days to retain RDS backups."
  type        = number
  default     = 7
}
# --- DB Backup Window ---
variable "db_backup_window" {
  description = "Daily time range (UTC) for RDS backups."
  type        = string
  default     = "03:00-04:00"
}
# --- DB Maintenance Window ---
variable "db_maintenance_window" {
  description = "Weekly time range (UTC) for RDS maintenance."
  type        = string
  default     = "Mon:04:00-Mon:04:30"
}
# --- DB Multi-AZ ---
variable "db_multi_az" {
  description = <<EOT
Whether to enable Multi-AZ deployment for high availability (true/false).
EOT
  type        = bool
  default     = true
}

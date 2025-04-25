#########################################
# rds.tf
# Production-Ready RDS PostgreSQL for n8n
#########################################

# --- Subnet Group for RDS (private subnets only) ---
resource "aws_db_subnet_group" "n8n_rds_subnet_group" {
  name       = "n8n-rds-subnet-group"
  subnet_ids = local.private_subnet_ids
  tags = merge(var.default_tags, {
    Name = "n8n-rds-subnet-group"
  })
}

# --- Parameter Group (optional: for custom Postgres settings) ---
resource "aws_db_parameter_group" "n8n_rds_pg" {
  name        = "n8n-rds-pg"
  family      = "postgres15"
  description = "Custom parameter group for n8n Postgres"
  tags        = var.default_tags

  # Example: tune max_connections (customize as needed)
  parameter {
    name         = "max_connections"
    value        = var.db_max_connections
    apply_method = "pending-reboot"
  }
}

# --- RDS PostgreSQL Instance ---
resource "aws_db_instance" "n8n_rds" {
  identifier                = var.db_identifier
  engine                    = "postgres"
  engine_version            = var.db_engine_version
  instance_class            = var.db_instance_class
  allocated_storage         = var.db_allocated_storage
  max_allocated_storage     = var.db_max_allocated_storage
  db_name                   = var.db_name
  username                  = var.db_username
  password                  = var.db_password
  db_subnet_group_name      = aws_db_subnet_group.n8n_rds_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.n8n_rds_sg.id]
  parameter_group_name      = aws_db_parameter_group.n8n_rds_pg.name
  backup_retention_period   = var.db_backup_retention
  backup_window             = var.db_backup_window
  maintenance_window        = var.db_maintenance_window
  multi_az                  = var.db_multi_az
  publicly_accessible       = false
  storage_encrypted         = true
  auto_minor_version_upgrade = true
  deletion_protection       = true
  skip_final_snapshot       = false
  apply_immediately         = false
  tags = merge(var.default_tags, {
    Name = "n8n-postgres"
  })
  # Enable CloudWatch logs for auditing (optional)
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}

# --- Security Group: Only allow EC2 security group to access Postgres ---
resource "aws_security_group" "n8n_rds_sg" {
  name        = "n8n-rds-sg"
  description = "Allow Postgres access from n8n EC2 only"
  vpc_id      = local.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.n8n_ec2_sg.id]
    description     = "Allow n8n EC2 to connect to Postgres"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }
  tags = merge(var.default_tags, {
    Name = "n8n-rds-sg"
  })
}

# --- Outputs ---
output "n8n_rds_endpoint" {
  description = "RDS Postgres endpoint for n8n connection"
  value       = aws_db_instance.n8n_rds.endpoint
}

output "n8n_rds_db_name" {
  description = "RDS database name for n8n"
  value       = aws_db_instance.n8n_rds.db_name
}

output "n8n_rds_username" {
  description = "RDS username for n8n"
  value       = aws_db_instance.n8n_rds.username
}

output "n8n_rds_security_group_id" {
  description = "Security group ID for RDS Postgres"
  value       = aws_security_group.n8n_rds_sg.id
}

# --- Documentation ---
# - All sensitive values (passwords) should be stored in a secure secrets manager or as Terraform variables.
# - Rotate credentials regularly for compliance.
# - Backup retention, encryption, and deletion protection are enabled for production safety.
# - This RDS instance is only accessible from the n8n EC2 security group.
# - Customize parameter group for advanced tuning as needed.

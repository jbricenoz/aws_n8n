#############################################
# security_groups.tf
# Security Groups for n8n AWS Production Stack
#############################################

# --- ALB Security Group ---
resource "aws_security_group" "n8n_alb_sg" {
  name        = "n8n-alb-sg"
  description = "Allow HTTP/HTTPS inbound to ALB"
  vpc_id      = local.vpc_id

  ingress {
    description = "Allow HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow HTTP from anywhere (redirected to HTTPS)"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.default_tags, {
    Name = "n8n-alb-sg"
  })
}


#############################################
# Documentation:
# - ALB SG: Open to the world for HTTP/HTTPS (frontend entrypoint)
# - EC2 SG: Only allows N8N traffic from ALB and SSH from trusted IP/CIDR
# - RDS SG: Only allows Postgres from n8n EC2 SG (never public)
# - Redis SG: Only allows Redis from n8n EC2 SG (never public)
# - All egress is open (restrict further for compliance if needed)
# - Use variables for VPC, trusted CIDRs, and tagging for cost/compliance
# - These SGs are referenced in ec2.tf, rds.tf, redis.tf, and load_balancer.tf

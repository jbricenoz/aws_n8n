
# Minimal terraform.tfvars - only user-required variables
route53_zone_name     = "modesignstudio.co"   # Required: your Route53 domain
budget_alert_email    = "jbriceno.qa@gmail.com" # Required: alerts
# Optional: override defaults if needed
db_password           = "your-secure-password" # Required: RDS password (never defaulted)
# aws_region        = "us-west-2"
# db_name           = "n8n"
# db_username       = "n8nuser"
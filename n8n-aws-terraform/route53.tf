##############################################
# route53.tf
# Route53 DNS for N8N (Production-Ready)
##############################################

# --- Data Source: Use existing Route53 hosted zone ---
data "aws_route53_zone" "selected" {
  name         = var.route53_zone_name  # e.g. "example.com."
  private_zone = false
}

# --- DNS Record: Point subdomain to ALB for SSL/Scaling ---
# For production, always point to ALB (not EC2) to enable HTTPS and scaling.
resource "aws_route53_record" "n8n_dns" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.n8n_subdomain}.${var.route53_zone_name}"
  type    = "A"
  alias {
    name                   = aws_lb.n8n_alb.dns_name
    zone_id                = aws_lb.n8n_alb.zone_id
    evaluate_target_health = true
  }
  # TTL is ignored for alias records
}

# --- Outputs ---
output "n8n_dns_record" {
  description = "The FQDN for your N8N instance (use this for N8N_HOST, WEBHOOK_URL, etc.)"
  value       = "${var.n8n_subdomain}.${var.route53_zone_name}"
}

# --- Documentation ---
# - This configuration uses your existing Route53 hosted zone (domain must be registered/managed in AWS).
# - The DNS record points to the ALB, ensuring HTTPS (SSL) and horizontal scaling.
# - Use the output FQDN in your Docker Compose/Bash configs for N8N_HOST and WEBHOOK_URL.
# - All resources are fully managed and work in sync with EC2, RDS, and Dockerized n8n.


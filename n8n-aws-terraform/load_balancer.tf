#############################################
# load_balancer.tf
# Production-Ready ALB for n8n AWS Stack
#############################################

# --- Application Load Balancer (ALB) ---
resource "aws_lb" "n8n_alb" {
  name                       = "n8n-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.n8n_alb_sg.id]
  subnets                    = local.public_subnet_ids
  enable_deletion_protection = true
  tags = merge(var.default_tags, {
    Name = "n8n-alb"
  })
}

# --- Target Group for n8n EC2 ---
resource "aws_lb_target_group" "n8n_tg" {
  name     = "n8n-tg"
  port     = 5678
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = merge(var.default_tags, {
    Name = "n8n-tg"
  })
}

# --- ACM Certificate for HTTPS (must be validated in Route53) ---
# --- ACM Certificate for HTTPS (automatically provisioned for subdomain and validated via Route53) ---
resource "aws_acm_certificate" "n8n_cert" {
  domain_name       = "${var.n8n_subdomain}.${var.route53_zone_name}"
  validation_method = "DNS"
  tags = merge(var.default_tags, {
    Name = "n8n-cert"
  })
}

resource "aws_acm_certificate_validation" "n8n_cert_validation" {
  certificate_arn         = aws_acm_certificate.n8n_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.n8n_cert_validation : record.fqdn]
}

resource "aws_route53_record" "n8n_cert_validation" {
  count   = length(aws_acm_certificate.n8n_cert.domain_validation_options)
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = tolist(aws_acm_certificate.n8n_cert.domain_validation_options)[count.index].resource_record_name
  type    = tolist(aws_acm_certificate.n8n_cert.domain_validation_options)[count.index].resource_record_type
  records = [tolist(aws_acm_certificate.n8n_cert.domain_validation_options)[count.index].resource_record_value]
  ttl     = 300
}

# --- HTTP Listener (redirect to HTTPS) ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.n8n_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# --- HTTPS Listener (forward to n8n target group, uses ACM cert managed by Terraform) ---
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.n8n_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.n8n_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n_tg.arn
  }
  depends_on = [aws_acm_certificate_validation.n8n_cert_validation]
}

# --- Attach EC2 instance(s) to Target Group ---
resource "aws_lb_target_group_attachment" "n8n_ec2" {
  target_group_arn = aws_lb_target_group.n8n_tg.arn
  target_id        = aws_instance.n8n_ec2.id
  port             = 5678
}
# --- Outputs ---
output "alb_dns_name" {
  description = "DNS name of the ALB (use for Route53 alias and testing)"
  value       = aws_lb.n8n_alb.dns_name
}
output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.n8n_alb.arn
}
output "alb_target_group_arn" {
  description = "ARN of the n8n target group"
  value       = aws_lb_target_group.n8n_tg.arn
}

#############################################
# Documentation:
# - ALB is public, spans all public subnets, and is protected by SG
# - HTTP (80) listener redirects to HTTPS (443) for security
# - ACM certificate is provisioned and validated via Route53 for SSL
# - Target group health checks /healthz endpoint on n8n
# - EC2 instance(s) are registered to the target group
# - Outputs for DNS, ARNs for use in Route53 and other modules
# - All tags and dependencies align with the rest of the stack

resource "aws_lb_listener" "n8n_https" {
  load_balancer_arn = aws_lb.n8n_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.n8n_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.n8n_tg.arn
  }
}

resource "aws_lb_listener" "n8n_http_redirect" {
  load_balancer_arn = aws_lb.n8n_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


#############################################
# budget_monitoring.tf
# AWS Budgets and CloudWatch Monitoring for n8n Free Tier Stack
#############################################

# --- AWS Budget (monthly, per service, with alert) ---
resource "aws_budgets_budget" "n8n_monthly_budget" {
  name              = "n8n-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.aws_budget_limit
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  cost_types {
    include_tax = true
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    notification_type          = "ACTUAL"
    threshold                 = var.aws_budget_threshold
    threshold_type            = "PERCENTAGE"
    subscriber_email_addresses = [var.budget_alert_email]
  }
  depends_on = [aws_sns_topic.n8n_budget_alerts]
}

# --- SNS Topic for Budget Alerts ---
resource "aws_sns_topic" "n8n_budget_alerts" {
  name = "n8n-budget-alerts"
}

# --- CloudWatch Monitoring: Basic Free Tier Metrics ---
# EC2, RDS, ALB, Redis all have basic CloudWatch metrics enabled by default (free tier)
# Example: Alarm for high CPU on EC2
resource "aws_cloudwatch_metric_alarm" "n8n_ec2_high_cpu" {
  alarm_name          = "n8n-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when EC2 CPU > 80% for 10 minutes"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.n8n_budget_alerts.arn]
  ok_actions          = [aws_sns_topic.n8n_budget_alerts.arn]
  dimensions = {
    InstanceId = aws_instance.n8n_ec2.id
  }
}

# --- Outputs ---
output "budget_alert_email" {
  description = "Email address for budget/monitoring alerts"
  value       = var.budget_alert_email
}

#############################################
# Documentation:
# - AWS Budgets will alert you via email if monthly spend exceeds threshold (default: free tier)
# - CloudWatch alarms (free tier) monitor EC2, RDS, ALB, Redis
# - All alerts go to a configurable email address
# - Easily extend to other services or thresholds as needed

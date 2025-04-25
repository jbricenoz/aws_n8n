// outputs.tf
// Outputs for useful information after applying the Terraform configuration.

// Define outputs such as EC2 public IP, RDS endpoint, etc.

output "ec2_public_ip" {
  description = "The public IP address of the N8N EC2 instance."
  value       = aws_instance.n8n_ec2.public_ip
}

output "ec2_public_dns" {
  description = "The public DNS of the N8N EC2 instance."
  value       = aws_instance.n8n_ec2.public_dns
}

output "ssh_access_cidr" {
  description = "The CIDR allowed for SSH access to EC2 (for documentation and config)."
  value       = local.ssh_access_cidr
}


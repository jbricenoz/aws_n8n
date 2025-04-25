# ec2_key.tf
# Automatically create an SSH key pair for the EC2 instance and output the private key (save this securely!)

resource "tls_private_key" "n8n_ec2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "n8n_ec2" {
  key_name   = "n8n-ec2-key"
  public_key = tls_private_key.n8n_ec2.public_key_openssh
}

output "ec2_private_key_pem" {
  description = "Private key for your EC2 instance (save this securely!)"
  value       = tls_private_key.n8n_ec2.private_key_pem
  sensitive   = true
}

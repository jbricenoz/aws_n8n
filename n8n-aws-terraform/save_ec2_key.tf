# Automatically save the generated EC2 private key to a file
resource "local_sensitive_file" "n8n_ec2_private_key" {
  content              = tls_private_key.n8n_ec2.private_key_pem
  filename             = "${path.module}/n8n-ec2-key.pem"
  file_permission      = "0600"
  directory_permission = "0700"
}

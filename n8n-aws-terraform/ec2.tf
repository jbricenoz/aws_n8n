// ec2.tf
// EC2 instance definition for running N8N in Docker with EBS volume for persistent n8n_data.

resource "aws_instance" "n8n_ec2" {
  ami                         = var.ec2_ami != "" ? var.ec2_ami : data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = var.ec2_instance_type
  subnet_id                   = local.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.n8n_ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.n8n_ec2.key_name
  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    rds_endpoint = aws_db_instance.n8n_rds.address
    db_name      = aws_db_instance.n8n_rds.db_name
    db_username  = aws_db_instance.n8n_rds.username
    db_password  = var.n8n_rds_password
    n8n_host     = "${var.n8n_subdomain}.${var.route53_zone_name}"
    WEBHOOK_URL  = "https://${var.n8n_subdomain}.${var.route53_zone_name}/"
  })

  tags = {
    Name = "n8n-ec2"
  }
}

resource "aws_ebs_volume" "n8n_data" {
  availability_zone = data.aws_subnet.n8n_public_0.availability_zone
  size              = var.n8n_data_ebs_size
  type              = var.n8n_data_ebs_type
  encrypted         = true
  tags = {
    Name = "n8n-data-ebs"
  }
}

resource "aws_volume_attachment" "n8n_data_attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.n8n_data.id
  instance_id = aws_instance.n8n_ec2.id
  force_detach = true
}

resource "aws_security_group" "n8n_ec2_sg" {
  name        = "n8n-ec2-sg"
  description = "Allow N8N traffic from ALB and SSH"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    security_groups = [aws_security_group.n8n_alb_sg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.ssh_access_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "n8n-ec2-sg"
  }
}

# ebs_data.tf
# Data source for subnet to get its AZ for EBS volume

data "aws_subnet" "n8n_public_0" {
  id = local.public_subnet_ids[0]
}

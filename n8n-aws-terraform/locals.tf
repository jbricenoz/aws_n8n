// locals.tf
// Automatically provide VPC and subnet IDs for all services

locals {
  # Advanced users can override *_subnet_cidrs by defining variables manually.
  az_count = length(data.aws_availability_zones.available.names)
  vpc_cidr = var.vpc_cidr != "" ? var.vpc_cidr : "10.0.0.0/16"

  public_subnet_cidrs = [for i in range(local.az_count) : cidrsubnet(local.vpc_cidr, 4, i)]
  private_subnet_cidrs = [for i in range(local.az_count) : cidrsubnet(local.vpc_cidr, 4, i + local.az_count)]

  vpc_id             = aws_vpc.n8n_vpc.id
  public_subnet_ids  = [for s in aws_subnet.n8n_public_subnet : s.id]
  private_subnet_ids = [for s in aws_subnet.n8n_private_subnet : s.id]
}

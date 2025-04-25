#############################################
# vpc.tf
# Production-Ready VPC for n8n AWS Stack
#############################################

# --- VPC ---
resource "aws_vpc" "n8n_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.default_tags, {
    Name = "n8n-vpc"
  })
}

# --- Public Subnets (2 AZs for HA) ---
resource "aws_subnet" "n8n_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.n8n_vpc.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(var.default_tags, {
    Name = "n8n-public-subnet-${count.index + 1}"
  })
}

# --- Private Subnets (2 AZs for HA) ---
resource "aws_subnet" "n8n_private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.n8n_vpc.id
  cidr_block        = local.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(var.default_tags, {
    Name = "n8n-private-subnet-${count.index + 1}"
  })
}

# --- Internet Gateway for Public Subnets ---
resource "aws_internet_gateway" "n8n_igw" {
  vpc_id = aws_vpc.n8n_vpc.id
  tags = merge(var.default_tags, {
    Name = "n8n-igw"
  })
}

# --- Elastic IP for NAT Gateway ---
resource "aws_eip" "n8n_nat_eip" {
  domain = "vpc"
  tags = merge(var.default_tags, {
    Name = "n8n-nat-eip"
  })
}

# --- NAT Gateway for Private Subnets ---
resource "aws_nat_gateway" "n8n_nat_gw" {
  allocation_id = aws_eip.n8n_nat_eip.id
  subnet_id     = aws_subnet.n8n_public_subnet[0].id
  tags = merge(var.default_tags, {
    Name = "n8n-nat-gw"
  })
  depends_on = [aws_internet_gateway.n8n_igw]
}

# --- Public Route Table ---
resource "aws_route_table" "n8n_public_rt" {
  vpc_id = aws_vpc.n8n_vpc.id
  tags = merge(var.default_tags, {
    Name = "n8n-public-rt"
  })
}

# --- Public Route: IGW ---
resource "aws_route" "n8n_public_internet" {
  route_table_id         = aws_route_table.n8n_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.n8n_igw.id
}

# --- Associate Public Subnets with Public Route Table ---
resource "aws_route_table_association" "n8n_public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.n8n_public_subnet[count.index].id
  route_table_id = aws_route_table.n8n_public_rt.id
}

# --- Private Route Table ---
resource "aws_route_table" "n8n_private_rt" {
  vpc_id = aws_vpc.n8n_vpc.id
  tags = merge(var.default_tags, {
    Name = "n8n-private-rt"
  })
}

# --- Private Route: NAT GW ---
resource "aws_route" "n8n_private_nat" {
  route_table_id         = aws_route_table.n8n_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.n8n_nat_gw.id
}

# --- Associate Private Subnets with Private Route Table ---
resource "aws_route_table_association" "n8n_private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.n8n_private_subnet[count.index].id
  route_table_id = aws_route_table.n8n_private_rt.id
}

# --- Outputs ---
output "vpc_id" {
  description = "VPC ID for n8n stack"
  value       = aws_vpc.n8n_vpc.id
}
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = aws_subnet.n8n_public_subnet[*].id
}
output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = aws_subnet.n8n_private_subnet[*].id
}
output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.n8n_nat_gw.id
}

#############################################
# Documentation:
# - VPC has DNS support/hostnames for service discovery
# - 2 public and 2 private subnets for HA (multi-AZ)
# - Public subnets host ALB, NAT GW; private subnets host EC2, RDS, Redis
# - NAT GW allows private subnet instances outbound internet access
# - All IDs are output for use in other .tf modules
# - All resources tagged for cost/compliance
# - Variables drive all CIDRs, AZs, and tags for flexibility

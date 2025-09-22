########################
# VPC
########################
resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

########################
# Availability Zones
########################
data "aws_availability_zones" "available" {}

########################
# Public Subnets (2)
########################
resource "aws_subnet" "public" {
  count = 2
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index) # splits into smaller blocks
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-public-${count.index}"
    "kubernetes.io/role/elb"                   = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

########################
# Private Subnets (2)
########################
resource "aws_subnet" "private" {
  count = 2
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 10)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.cluster_name}-private-${count.index}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

########################
# Internet Gateway
########################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

########################
# Elastic IPs for NAT
########################
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "${var.cluster_name}-nat-eip-${count.index}"
  }
}

########################
# NAT Gateways (1 per AZ in public subnets)
########################
resource "aws_nat_gateway" "nat" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.cluster_name}-nat-${count.index}"
  }
}

########################
# Public Route Table
########################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

# Route public subnets to Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnets with public RT
resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

########################
# Private Route Tables (1 per AZ)
########################
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "${var.cluster_name}-private-rt-${count.index}"
  }
}

# Route private subnets to their NAT Gateway
resource "aws_route" "private_nat" {
  count                  = 2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

# Associate private subnets with private RT
resource "aws_route_table_association" "private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

########################
# Outputs
########################
output "vpc_id" {
  value = aws_vpc.dev.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

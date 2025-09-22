# VPC
resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

# Data source for AZs
data "aws_availability_zones" "available" {}

# Private subnets (2)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.dev.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.cluster_name}-private-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Public subnet (1)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.dev.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 100)
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.cluster_name}-public"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "${var.cluster_name}-igw"
  }
}


# NAT Gateway in public subnet
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "${var.cluster_name}-nat"
  }
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

# Route public subnet to IGW
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.dev.id
  tags = {
    Name = "${var.cluster_name}-private-rt"
  }
}

# Route private subnets to NAT
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate private subnets
resource "aws_route_table_association" "private_assoc" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Outputs
output "vpc_id" {
  value = aws_vpc.dev.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

resource "aws_vpc" "dev" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

resource "aws_subnet" "private" {
  count = 2
  vpc_id     = aws_vpc.dev.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = {
    Name = "${var.cluster_name}-private-${count.index}"
  }
}

data "aws_availability_zones" "available" {}

output "vpc_id" {
  value = aws_vpc.dev.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

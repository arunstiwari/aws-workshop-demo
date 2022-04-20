# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support = var.enable_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name_prefix}-vpc"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name_prefix}-igw"
    }
  )
}

# Create AWS Public Subnets
resource "aws_subnet" "pub_sub" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.availability_zones)
  availability_zone = element(var.availability_zones,count.index )
  cidr_block = element(var.public_subnets_cidr_per_az, count.index )
  map_public_ip_on_launch = true // this cause the subnet to be created as public subnet
  tags = merge(
    var.additional_tags,
    {
      Name: "${var.name_prefix}-pub-net-${element(var.availability_zones,count.index )}"
    }
  )
}

# Elastic IPs for NAT

resource "aws_eip" "nat_eip" {
  count = var.single_nat ? 1 : length(var.availability_zones)
  vpc = true
  tags = merge(
    var.additional_tags,
    {
     Name = "${var.name_prefix}-nat-eip-${element(var.availability_zones, count.index)}"
  })
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  count = var.single_nat ? 1 : length(var.availability_zones)
  allocation_id = var.single_nat ? aws_eip.nat_eip.0.id : element(aws_eip.nat_eip.*.id, count.index)
  subnet_id = var.single_nat ? aws_subnet.pub_sub.0.id : element(aws_subnet.pub_sub.*.id, count.index)
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name_prefix}-nat-gw-${element(var.availability_zones, count.index )}"
    }
  )
  depends_on = [
    aws_internet_gateway.igw
  ]
}

# Public Route table
resource "aws_route_table" "pub_sub_route_table" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.availability_zones)
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name_prefix}-public-rt-${element(var.availability_zones,count.index )}"
    }
  )
}

# Public route to access Internet
resource "aws_route" "pub_internet_rt" {
  count = length(var.availability_zones)
  depends_on = [
    aws_internet_gateway.igw,
    aws_route_table.pub_sub_route_table
  ]
  route_table_id = element(aws_route_table.pub_sub_route_table.*.id, count.index )
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

# Association of route tables to subnets
resource "aws_route_table_association" "pub_internet_rt_association" {
  count = length(var.availability_zones)
  subnet_id = element(aws_subnet.pub_sub.*.id, count.index )
  route_table_id = element(aws_route_table.pub_sub_route_table.*.id, count.index )
}

# AWS Subnets - Private
resource "aws_subnet" "pvt_subnet" {
  vpc_id = aws_vpc.vpc.id
  count = length(var.availability_zones)
  availability_zone = element(var.availability_zones.count.index)
  cidr_block = element(var.pvt_subnet_cidrs_per_az, count.index )
  map_public_ip_on_launch = false
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name_prefix}-pvt-net-${element(var.availability_zones, count.index)}"
    }
  )
}

# Private Route table
resource "aws_route_table" "pvt_subnet_route_table" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name_prefix}-pvt-rt-${element(var.availability_zones, count.index )}"
    }
  )
}

# Private route to access Internet
resource "aws_route" "pvt_internet_route" {
  count =
  route_table_id = ""
}
#Create VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.common_tags,
    var.vpc_tags, 
    {
    Name = local.resource_name
    }
  )
}

#Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.igw_tags, 
    {
    Name = local.resource_name
    }
  )
}

# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

#Create subnets for public
resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    var.public_subnet_tags, 
    {
    Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}

#Create subnets for private
resource "aws_subnet" "private_subnets" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_tags, 
    {
    Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}

#Create subnets for database
resource "aws_subnet" "database_subnets" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_tags, 
    {
    Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}

#aws database subnet group
resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database_subnets[*].id

  tags = merge(
    var.common_tags,
    var.db_subnet_group_tags, 
    {
    Name = local.resource_name
    }
  )
}

#CREATE NAT Gateway
#Create Elactic IP
resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = {
    Name = "eip-${var.project_name}"
  }
}

#CREATE NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id  #here we need elastic IP
  subnet_id     = aws_subnet.public_subnets[0].id   #for cost saving and practicing we keep nat gateway in us-east-1a only

  tags = merge(
    var.common_tags,
    var.nat_gateway_tags, 
    {
    Name = local.resource_name
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}

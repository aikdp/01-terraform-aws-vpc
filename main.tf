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
  map_public_ip_on_launch = true  #assign to public yes

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

#CREATE Route table for Public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.public_route_tables_tags,
    {
    Name = "${local.resource_name}-public"
  }
)
}

#CREATE Route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.private_route_tables_tags,
    {
    Name = "${local.resource_name}-private"
  }
)
}
#CREATE Route table for database subnet
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    var.database_route_tables_tags,
    {
    Name = "${local.resource_name}-database"
  }
)
}

#ADD routes
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}
#ADD routes
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.main.id
}
#ADD routes
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_nat_gateway.main.id
}

#Route table associations 
# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.public_subnets[0].id
#   route_table_id = aws_route_table.public.id
# }
# resource "aws_route_table_association" "a" {
#   subnet_id      = aws_subnet.public_subnets[1].id
#   route_table_id = aws_route_table.public.id
# }

#WE CAN COUNT TO ITERATE 2 subnet ids for one routetable
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

#WE CAN COUNT TO ITERATE 2 subnet ids for one routetable
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private.id
}
#WE CAN COUNT TO ITERATE 2 subnet ids for one routetable
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database_subnets[count.index].id
  route_table_id = aws_route_table.database.id
}

#ADD VPC Peering COnnection expense-dev-vpc to default: requestor is expense-dev-vpc and Acceptor is Default
resource "aws_vpc_peering_connection" "peering" {
  count = var.is_peer_required ? 1 : 0
  peer_vpc_id   = data.aws_vpc.default.id #Acceptor VPC ID
  vpc_id        = aws_vpc.main.id #Requestor VPC ID
  auto_accept   = true

  tags = merge (
    var.common_tags,
    var.vpc_peering_tags,
    {
    Name = "${local.resource_name}-default"
    }
  )
}

#ADD routes to peering-->which subnet will wants to connect with other vpc
resource "aws_route" "public_peer" {
  count = var.is_peer_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}
#ADD routes to peering
resource "aws_route" "private_peer" {
  count = var.is_peer_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

#ADD routes to peering
resource "aws_route" "database_peer" {
  count = var.is_peer_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}


#ADD routes to Default VPC
resource "aws_route" "default_peer" {
  count = var.is_peer_required ? 1 : 0
  route_table_id            = data.aws_route_table.main.route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

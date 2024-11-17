# Terraform AWS VPC Moduele Customized

This module is going to create the following repources. For HA we are going to get first 2 AZ
 
 * VPC
 * Internet GAteway associted with VPC
 * 2 Public Subenets
 * 2 Private Subnets
 * 2 database subnets
 * database subnet group
 * EIP
 * NAT Gateway
 * Public Route Table
 * Private Route Table
 * database Route Table
 * Routes
 * Route Table associations with subnets
 * Peering with default VPC (if required)
 * Peering routes in accpetors and requestors rout tables 

 # Inputs

 * Project_name (Mandatory): User must supply their project name.
 * environment (Mandatory): User must supply their environment.
 * vpc_cidr (Mandatory): User must supply their VPC CIDR.
 * enable_dns_hostnames (optional): Defaults is to true
 * common_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * vpc_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * igw_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * public_subnet_cidrs (Mandatory): User must supply 2 valid public subnet CIDR.
 * public_subnet_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * private_subnet_cidrs (Mandatory): User must supply 2 valid private subnet CIDR.
 * private_subnet_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * database_subnet_cidrs (Mandatory): User must supply 2 valid database subnet CIDR.
 * database_subnet_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * db_subnet_groups_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * nat_gateway_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * public_route_table_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * private_rout_table_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * database_route_table_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.
 * is_peering_required (optional): Defaults to false
 * vpc_peering_tags (optional): Default is empty. User can supply tags in map of strings (map(string)) format.

 # Outputs

 * vpc_id: VPC ID Craeted
 * public_subnet_ids: map of two prublic subnet ids created
 * private_subnet_ids: map of two private subnet ids created
 * database_subnet_ids: map of two database subnet ids created
##user should supply, while using this module
variable "vpc_cidr"{
    type = string
}

variable "enable_dns_hostnames" {
    default = true
}

#common tgas are optional
variable "common_tags"{
    default = {}
}

#vpc can also optional
variable "vpc_tags"{
    default = {}
}

#user should supply, while using this module
variable "project_name"{
    type = string
}

#user should supply, while using this module
variable "environment" {
    type = string
}

#igw_tags
variable "igw_tags"{
    default = {}
}

variable "public_subnet_cidrs" {
  type = list

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Please provide 2 valid public subnet cidr"
  }
}

variable "public_subnet_tags"{
    default = {}
}

variable "private_subnet_cidrs" {
  type = list

  validation {
    condition     = length(var.private_subnet_cidrs) == 2
    error_message = "Please provide 2 valid private subnet cidr"
  }
}

variable "private_subnet_tags"{
    default = {}
}

variable "database_subnet_cidrs" {
  type = list

  validation {
    condition     = length(var.database_subnet_cidrs) == 2
    error_message = "Please provide 2 valid database subnet cidr"
  }
}
variable "database_subnet_tags"{
    default = {}
}

variable "db_subnet_group_tags"{
    default = {}
}

variable "nat_gateway_tags"{
    default = {}
}

variable "public_route_tables_tags"{
    default = {}
}
variable "private_route_tables_tags"{
    default = {}
}
variable "database_route_tables_tags"{
    default = {}
}

variable "is_peer_required"{
    type = bool
    default = false
}
variable "vpc_peering_tags"{
    default = {}
}
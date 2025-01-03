output "vpc_id" {
    value = aws_vpc.main.id
}

output "az_info"{
    value = data.aws_availability_zones.available
}

output "public_subnet_ids"{
    value = aws_subnet.public_subnets[*].id
}
output "private_subnet_ids"{
    value = aws_subnet.public_subnets[*].id
}
output "database_subnet_ids"{
    value = aws_subnet.public_subnets[*].id
}

output "database_subnet_group_name"{
    value = aws_db_subnet_group.default.name
}
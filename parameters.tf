#Strore VPC ID
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project_name}/${var.environment}/vpc_id"
  type  = "String"
  value = aws_vpc.main.id
  }

  #Strore public_subnet_ids
resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/public_subnet_ids"
  type  = "StringList"
  value = join(",", aws_subnet.public_subnets[*].id)
  }

  #Strore private_subnet_ids
resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/private_subnet_ids"
  type  = "StringList"
  value = join(",", aws_subnet.private_subnets[*].id)
  }

  #Strore database_subnet_ids
resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/database_subnet_ids"
  type  = "StringList"
  value = join(",", aws_subnet.database_subnets[*].id)
  }
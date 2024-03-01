resource "aws_vpc" "app_runner_vpc" {
  cidr_block = "10.10.0.0/16"

  tags = {
    Service = "App Runner"
  }
}

resource "aws_subnet" "private_be_subnet" {
  vpc_id     = aws_vpc.app_runner_vpc.id
  cidr_block = "10.10.10.0/24"

  tags = {
    Service = "App Runner"
  }
}

resource "aws_security_group" "private_security_group" {
  name        = "Private BE Security Group"
  description = "Allow only traffic from FE"
  vpc_id      = aws_vpc.app_runner_vpc.id

  ingress {
    description = "Only allow incoming port on BE server"
    from_port   = 3001
    to_port     = 3001
    cidr_blocks = [aws_subnet.private_be_subnet.cidr_block]
    protocol = "tcp"
  }

  # Don't specify to allow all
  # egress = {

  # }

  tags = {
    Service = "App Runner"
  }
}

resource "aws_security_group" "public_security_group" {
  name        = "Public BE Security Group"
  description = "Allow only traffic from FE"
  vpc_id      = aws_vpc.app_runner_vpc.id

  ingress {
    description = "Only allow incoming port on FE server"
    from_port   = 80
    to_port     = 3000
    cidr_blocks = [aws_subnet.private_be_subnet.cidr_block]
    protocol = "tcp"
  }

  # Don't specify to allow all
  # egress = {

  # }

  tags = {
    Service = "App Runner"
  }
}

resource "aws_subnet" "public_fe_subnet" {
  vpc_id     = aws_vpc.app_runner_vpc.id
  cidr_block = "10.10.20.0/24"

  tags = {
    Service = "App Runner"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app_runner_vpc.id

  tags = {
    Service = "App Runner"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.app_runner_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Service = "App Runner"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
 subnet_id      = aws_subnet.public_fe_subnet.id
 route_table_id = aws_route_table.route_table.id
}

# resource "aws_route" "public_to_private_route" {
#   route_table_id            = route_table_id
#   destination_cidr_block    = "10.0.1.0/22"
#   vpc_peering_connection_id = "pcx-45ff3dc1"
#   depends_on                = [aws_route_table.testing]
# }

resource "aws_security_group" "internal_only_security_group" {
  name        = "Internally Public FE Security Group"
  description = "Allow only traffic from within VPC"
  vpc_id      = aws_vpc.app_runner_vpc.id

  ingress {
    description = "Only allow incoming port on BE server"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [aws_subnet.public_fe_subnet.cidr_block]
    protocol = "tcp"
  }

  # Don't specify to allow all
  # egress = {

  # }

  tags = {
    Service = "App Runner"
  }
}

output "vpc_private_subnet_id" {
  value = aws_subnet.private_be_subnet.id
  sensitive = false
}

output "vpc_public_subnet_id" {
  value = aws_subnet.public_fe_subnet.id
  sensitive = false
}

output "vpc_private_security_group_id" {
  value = aws_security_group.private_security_group.id
  sensitive = false
}

output "vpc_public_security_group_id" {
  value = aws_security_group.public_security_group.id
  sensitive = false
}
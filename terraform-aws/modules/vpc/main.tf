# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.main_vpc_cidr

  # Required for EKS
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "${var.project_name}-vpc"
  }
}


# Subnets
## AZ 1
resource "aws_subnet" "eks1_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.az1
  cidr_block        = var.subnet_eks1_cidr

  tags = {
    "Name" = "${var.project_name}-subnet-eks1"
  }
}

resource "aws_subnet" "rds1_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.az1
  cidr_block        = var.subnet_rds1_cidr

  tags = {
    "Name" = "${var.project_name}-subnet-rds1"
  }
}

resource "aws_subnet" "alb1_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.az1
  cidr_block        = var.subnet_alb1_cidr

  tags = {
    "Name"                   = "${var.project_name}-subnet-alb1"
    "kubernetes.io/role/elb" = "1"
  }
}


## AZ 2
resource "aws_subnet" "eks2_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.az2
  cidr_block        = var.subnet_eks2_cidr

  tags = {
    "Name" = "${var.project_name}-subnet-eks2"
  }
}

resource "aws_subnet" "rds2_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.az2
  cidr_block        = var.subnet_rds2_cidr

  tags = {
    "Name" = "${var.project_name}-subnet-eks1"
  }
}

resource "aws_subnet" "alb2_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.az2
  cidr_block        = var.subnet_alb2_cidr

  tags = {
    "Name"                   = "${var.project_name}-subnet-alb2"
    "kubernetes.io/role/elb" = "1"
  }
}


## AZ 3
resource "aws_subnet" "bastion_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.az3
  cidr_block        = var.subnet_bastion_cidr

  tags = {
    "Name" = "${var.project_name}-subnet-bastion"
  }
}
resource "aws_subnet" "natgw_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  availability_zone = var.az3
  cidr_block        = var.subnet_natgw_cidr

  tags = {
    "Name" = "${var.project_name}-subnet-natgw"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "default_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.project_name}-igw"
  }
}


# External IP & NAT Gateway
resource "aws_eip" "default_natgw_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.default_igw]
}

resource "aws_nat_gateway" "default_natgw" {
  allocation_id = aws_eip.default_natgw_eip.id
  subnet_id     = aws_subnet.natgw_subnet.id

  tags = {
    "Name" = "${var.project_name}-natgw"
  }
  depends_on = [aws_internet_gateway.default_igw]
}


# Route tables & associations
## Private subnets: EKS & RDS
resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    "Name" = "${var.project_name}-private-rtb"
  }
}

resource "aws_route_table_association" "private_eks_1" {
  route_table_id = aws_route_table.private_rtb.id
  subnet_id      = aws_subnet.eks1_subnet.id
}

resource "aws_route_table_association" "private_eks_2" {
  route_table_id = aws_route_table.private_rtb.id
  subnet_id      = aws_subnet.eks2_subnet.id
}

resource "aws_route_table_association" "private_rds_1" {
  route_table_id = aws_route_table.private_rtb.id
  subnet_id      = aws_subnet.rds1_subnet.id
}

resource "aws_route_table_association" "private_rds_2" {
  route_table_id = aws_route_table.private_rtb.id
  subnet_id      = aws_subnet.rds2_subnet.id
}


## Public subnets: ALB & NAT Gateway
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_igw.id
  }

  tags = {
    "Name" = "${var.project_name}-public-rtb"
  }
}

resource "aws_route_table_association" "public_alb_1" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id      = aws_subnet.alb1_subnet.id
}

resource "aws_route_table_association" "public_alb_2" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id      = aws_subnet.alb2_subnet.id
}

resource "aws_route_table_association" "public_natgw" {
  route_table_id = aws_route_table.public_rtb.id
  subnet_id      = aws_subnet.natgw_subnet.id
}


## SSM Bastion subnet (private, connect to NAT Gateway only)
resource "aws_route_table" "bastion_rtb" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default_natgw.id
  }

  tags = {
    "Name" = "${var.project_name}-bastion-rtb"
  }
}

resource "aws_route_table_association" "bastion" {
  route_table_id = aws_route_table.bastion_rtb.id
  subnet_id      = aws_subnet.bastion_subnet.id
}

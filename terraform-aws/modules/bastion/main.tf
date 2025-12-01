# AWS AMI used for the bastions
data "aws_ami" "al2023-arm64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }
}



### Bastion for EKS Cluster ###

# IAM Role, Policies, and the Instance Profile
resource "aws_iam_role" "bastion_eks_role" {
  name = "${var.project_name}-bastion-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_bastion_eks" {
  role       = aws_iam_role.bastion_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "eks_describe_cluster_policy" {
  name = "${var.project_name}-EKSDescribeCluster"
  role = aws_iam_role.bastion_eks_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion_eks_profile" {
  name = "${var.project_name}-bastion-eks-profile"
  role = aws_iam_role.bastion_eks_role.name
}


# Security Group
resource "aws_security_group" "bastion_eks_sg" {
  name        = "${var.project_name}-bastion-eks-sg"
  description = "SG of bastion host for EKS cluster"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-bastion-eks-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_eks_allow_https" {
  security_group_id = aws_security_group.bastion_eks_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}


# Key pair
resource "aws_key_pair" "bastion_eks" {
  key_name   = "${var.project_name}-bastion-eks"
  public_key = file(pathexpand("~/.ssh/eks-demo-bastion-eks.pub"))
}


# EC2 Instance
resource "aws_instance" "bastion_eks" {
  ami                    = data.aws_ami.al2023-arm64.id
  instance_type          = "t4g.nano"
  key_name               = aws_key_pair.bastion_eks.key_name
  subnet_id              = var.subnet_ids.bastion
  vpc_security_group_ids = [aws_security_group.bastion_eks_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion_eks_profile.name

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-bastion-eks"
  }
}



### Bastion for RDS Cluster ###

# IAM Role, Policies, and the Instance Profile
resource "aws_iam_role" "bastion_rds_role" {
  name = "${var.project_name}-bastion-rds-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_bastion_rds" {
  role       = aws_iam_role.bastion_rds_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_rds_profile" {
  name = "${var.project_name}-bastion-rds-profile"
  role = aws_iam_role.bastion_rds_role.name
}


# Security Group
resource "aws_security_group" "bastion_rds_sg" {
  name        = "${var.project_name}-bastion-rds-sg"
  description = "SG of bastion host for RDS instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-bastion-rds-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_rds_allow_https" {
  security_group_id = aws_security_group.bastion_rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "bastion_rds_allow_postgresql" {
  security_group_id = aws_security_group.bastion_rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
}


# Key pair
resource "aws_key_pair" "bastion_rds" {
  key_name   = "${var.project_name}-bastion-rds"
  public_key = file(pathexpand("~/.ssh/eks-demo-bastion-rds.pub"))
}


# EC2 Instance
resource "aws_instance" "bastion_rds" {
  ami                    = data.aws_ami.al2023-arm64.id
  instance_type          = "t4g.nano"
  key_name               = aws_key_pair.bastion_rds.key_name
  subnet_id              = var.subnet_ids.bastion
  vpc_security_group_ids = [aws_security_group.bastion_rds_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.bastion_rds_profile.name

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "${var.project_name}-bastion-rds"
  }
}

# IAM Roles, Policies, and Instance Profiles
## For EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = ["sts:AssumeRole", "sts:TagSession"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy" "eks_manage_nodes_policy" {
  name = "${var.project_name}-eks-manage-nodes-policy"
  role = aws_iam_role.eks_cluster_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:CreateTags"
        ],
        "Resource" : "arn:aws:ec2:*:*:instance/*",
        "Condition" : {
          "ForAnyValue:StringLike" : {
            "aws:TagKeys" : "kubernetes.io/cluster/*"
          }
        }
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeVpcs",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstanceTopology",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}


## For Worker Nodegroup (general)
resource "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.eks_node_role.name
}


# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.34"

  vpc_config {
    subnet_ids = [
      var.subnet_ids.eks1,
      var.subnet_ids.eks2
    ]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]

  tags = {
    Name = "${var.project_name}-eks-cluster"
  }
}


# Security group inbound rule for bastion host
resource "aws_vpc_security_group_ingress_rule" "bastion_to_eks_api" {
  security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description       = "Allow bastion host to access EKS API server"

  referenced_security_group_id = var.bastion_eks_sg_id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}


# Access entry & associated admin policy for  bastion host
resource "aws_eks_access_entry" "bastion" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.bastion_eks_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "bastion_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = var.bastion_eks_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.bastion]
}


# EC2 Launch Template & EKS Node group
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.project_name}-eks-node-"
  description = "Launch template for EKS worker nodes"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      iops                  = 3000
      throughput            = 125
      delete_on_termination = true
      encrypted             = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2 # For containerized apps
    instance_metadata_tags      = "enabled"
  }

  vpc_security_group_ids = [
    aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  ]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-eks-node"
    }
  }
}

resource "aws_eks_node_group" "general" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "general"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids = [
    var.subnet_ids.eks1,
    var.subnet_ids.eks2
  ]

  ami_type       = "AL2023_ARM_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  instance_types = ["t4g.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 6
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_policy,
  ]

  tags = {
    Name = "${var.project_name}-eks-nodegroup-general"
  }
}


# VPC Endpoints
## Interface endpoints
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region_primary}.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    var.subnet_ids.eks1,
    var.subnet_ids.eks2
  ]
  security_group_ids  = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-endpoint-ec2"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region_primary}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    var.subnet_ids.eks1,
    var.subnet_ids.eks2
  ]
  security_group_ids  = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-endpoint-ecr-api"
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region_primary}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    var.subnet_ids.eks1,
    var.subnet_ids.eks2
  ]
  security_group_ids  = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-endpoint-ecr-dkr"
  }
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region_primary}.sts"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    var.subnet_ids.eks1,
    var.subnet_ids.eks2
  ]
  security_group_ids  = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-endpoint-sts"
  }
}

## Gateway endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region_primary}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_ids.private]

  tags = {
    Name = "${var.project_name}-endpoint-s3"
  }
}

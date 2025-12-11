# S3 Artifact Bucket
resource "aws_s3_bucket" "frontend_artifact_bucket" {
  bucket = "${var.project_name}-frontend-pipeline-artifact"
}

resource "aws_s3_bucket_public_access_block" "frontend_artifact_bucket_pab" {
  bucket                  = aws_s3_bucket.frontend_artifact_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_artifact_bucket_encryption" {
  bucket = aws_s3_bucket.frontend_artifact_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# IAM Roles
resource "aws_iam_role" "frontend_codepipeline_service_role" {
  name = "${var.project_name}-frontend-codepipeline-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "frontend_codebuild_service_role" {
  name = "${var.project_name}-frontend-codebuild-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "frontend_codebuild_eks_admin_role" {
  name = "${var.project_name}-frontend-codebuild-eks-admin-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = aws_iam_role.frontend_codebuild_service_role.arn
      }
      Action = "sts:AssumeRole"
    }]
  })
}


# CodeConnection Reference
data "aws_codestarconnections_connection" "github" {
  name = var.codeconnection_github_name
}


# CodeBuild Project
resource "aws_codebuild_project" "frontend" {
  name         = "${var.project_name}-frontend-codebuild-project"
  service_role = aws_iam_role.frontend_codebuild_service_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-aarch64-standard:3.0"
    type                        = "ARM_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "EKS_CLUSTER_NAME"
      value = var.eks_cluster_name
    }
    environment_variable {
      name  = "EKS_ROLE_ARN"
      value = aws_iam_role.frontend_codebuild_eks_admin_role.arn
    }
    environment_variable {
      name  = "ECR_URI"
      value = split("/", var.ecr_app_urls.frontend)[0] # Registry part
    }
    environment_variable {
      name  = "ECR_REPOSITORY"
      value = split("/", var.ecr_app_urls.frontend)[1] # Repository part
    }
  }

  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = [var.subnet_ids.bastion]
    security_group_ids = [var.bastion_eks_sg_id]
  }
}


# IAM Policies
## For CodePipeline’s Service Role
resource "aws_iam_role_policy" "codepipeline_base_policy" {
  name = "CodePipelineBasePolicy"
  role = aws_iam_role.frontend_codepipeline_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.frontend_artifact_bucket.arn}",
          "${aws_s3_bucket.frontend_artifact_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region_primary}:${var.aws_account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection",
          "codeconnections:UseConnection"
        ]
        Resource = data.aws_codestarconnections_connection.github.arn
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:StartBuildBatch"
        ]
        Resource = aws_codebuild_project.frontend.arn
      }
    ]
  })
}

## For CodeBuild's Service Role
resource "aws_iam_role_policy" "codebuild_base_policy" {
  name = "CodeBuildBasePolicy"
  role = aws_iam_role.frontend_codebuild_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.frontend_artifact_bucket.arn}",
          "${aws_s3_bucket.frontend_artifact_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region_primary}:${var.aws_account_id}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
        ]
        Resource = "arn:aws:codebuild:${var.region_primary}:${var.aws_account_id}:report-group/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_vpc_policy" {
  name = "CodeBuildVPCPolicy"
  role = aws_iam_role.frontend_codebuild_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
        ]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = "ec2:CreateNetworkInterfacePermission"
        Resource = "arn:aws:ec2:${var.region_primary}:${var.aws_account_id}:network-interface/*"
        Condition = {
          StringEquals = {
            "ec2:Subnet"            = [var.subnet_arns.bastion]
            "ec2:AuthorizedService" = "codebuild.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_service_ecr" {
  role       = aws_iam_role.frontend_codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy" "codebuild_service_assume_eks" {
  name = "AssumeEKSAdminRole"
  role = aws_iam_role.frontend_codebuild_service_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "sts:AssumeRole"
      Resource = aws_iam_role.frontend_codebuild_eks_admin_role.arn
    }]
  })
}

## For CodeBuild's EKS Admin Role
resource "aws_iam_role_policy" "eks_describe_cluster_policy" {
  name = "EKSDescribeCluster"
  role = aws_iam_role.frontend_codebuild_eks_admin_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "eks:DescribeCluster"
      ]
      Resource = "*"
    }]
  })
}


# Access entry & associated admin policy for CodeBuild
resource "aws_eks_access_entry" "frontend_codebuild" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.frontend_codebuild_eks_admin_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "frontend_codebuild_admin" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_eks_access_entry.frontend_codebuild.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.frontend_codebuild]
}


# CodePipeline project
resource "aws_codepipeline" "codepipeline" {
  name           = "${var.project_name}-frontend-codepipeline-project"
  role_arn       = aws_iam_role.frontend_codepipeline_service_role.arn
  pipeline_type  = "V2" # Required for execution_mode and trigger 
  execution_mode = "SUPERSEDED"

  artifact_store {
    location = aws_s3_bucket.frontend_artifact_bucket.bucket
    type     = "S3"
  }

  trigger {
    provider_type = "CodeStarSourceConnection"

    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = ["main"]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.github.arn
        FullRepositoryId = "MortredN/eks-demo-coffeeshop-frontend"
        BranchName       = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.frontend.name
      }
    }
  }
}

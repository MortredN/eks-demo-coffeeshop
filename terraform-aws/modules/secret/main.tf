# Additional Secrets
resource "aws_secretsmanager_secret" "token_secret" {
  name = "${var.project_name}-token-secret"
}


# Secrets Store CSI
## IAM Role for Customer App
resource "aws_iam_role" "sscsi_customer_role" {
  name = "${var.project_name}-sscsi-customer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_eks_cluster_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_eks_cluster_url, "https://", "")}:sub" = "system:serviceaccount:default:aws-secrets-manager-sscsi-customer"
            "${replace(var.oidc_eks_cluster_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "sscsi_customer_policy" {
  name = "${var.project_name}-sscsi-customer-policy"
  role = aws_iam_role.sscsi_customer_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          var.rds_db_customer_secret_arn,
          aws_secretsmanager_secret.token_secret.arn
        ]
      }
    ]
  })
}


## IAM Role for Shopping App
resource "aws_iam_role" "sscsi_shopping_role" {
  name = "${var.project_name}-sscsi-shopping-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_eks_cluster_arn
        }
        Condition = {
          StringEquals = {
            "${replace(var.oidc_eks_cluster_url, "https://", "")}:sub" = "system:serviceaccount:default:aws-secrets-manager-sscsi-shopping"
            "${replace(var.oidc_eks_cluster_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "sscsi_shopping_policy" {
  name = "${var.project_name}-sscsi-shopping-policy"
  role = aws_iam_role.sscsi_shopping_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          var.rds_db_shopping_secret_arn,
          aws_secretsmanager_secret.token_secret.arn
        ]
      }
    ]
  })
}

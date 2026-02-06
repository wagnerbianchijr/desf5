resource "aws_kms_key" "this" {
  description             = "KMS key for encrypting VPC Flow Logs and CloudWatch Logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "key-default-1",
    Statement = [
      {
        Sid    = "AllowRootAccountAccess",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*",
        Resource = "*"
      },
      {
        Sid    = "AllowVPCFlowLogsService",
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsUnconditional",
        Effect = "Allow",
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        },
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    project_owner_tag = var.project_owner_tag
    environment_tag   = var.environment_tag
    cost_center_tag   = var.cost_center_tag
    created_by_tag    = var.created_by_tag
    terraformed_tag   = var.terraformed_tag
  }
}

resource "aws_kms_alias" "this" {
  name          = "alias/kms_key_for_vpc_flow_logs_${var.environment_tag}"
  target_key_id = aws_kms_key.this.arn
}
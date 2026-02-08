/*
  =============================================================================
  Module:        kms
  File:          main.tf
  Owner:         Wagner “Bianchi” Bianchi
  Role:          Database & Cloud Infrastructure
  Repository:    https://github.com/wagnerbianchijr/desf5
  Documentation: https://github.com/wagnerbianchijr/desf5
  License:       GPL-3.0 license

  Purpose:
    This module provisions a KMS Key in AWS, which is used for encrypting VPC 
    Flow Logs and CloudWatch Logs. The KMS Key is configured with a custom 
    policy that allows access to the root account, VPC Flow Logs service, and 
    CloudWatch Logs service.

  Usage Notes:
    - Ensure that the KMS Key is created in the same region as the resources that 
      will be using it for encryption.
    - The KMS Key policy is configured to allow access to the root account and 
      specific AWS services; modify the policy as needed to fit your security 
      requirements.
    - This module does not include the resources that will use the KMS Key; it 
      should be used in conjunction with modules that provision those resources.

  Compatibility:
    Terraform:    >= 1.14.2
    Providers:    AWS
    Tested On:    1.14.2

  Contact:
    For questions or issues, please open an issue in the GitHub repository or 
    contact the owner directly.
  =============================================================================
*/

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
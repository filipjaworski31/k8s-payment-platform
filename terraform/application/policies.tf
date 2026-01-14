# ============================================
# ECR Lifecycle Policies
# ============================================

resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name

  policy = jsonencode({
    rules = [
      # Rule 1: Keep last N tagged images
      {
        rulePriority = local.lifecycle_rules.tagged_images.priority
        description  = local.lifecycle_rules.tagged_images.description
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = local.lifecycle_rules.tagged_images.tag_prefixes
          countType     = local.lifecycle_rules.tagged_images.count_type
          countNumber   = local.lifecycle_rules.tagged_images.count_number
        }
        action = {
          type = "expire"
        }
      },
      # Rule 2: Remove old untagged images
      {
        rulePriority = local.lifecycle_rules.untagged_images.priority
        description  = local.lifecycle_rules.untagged_images.description
        selection = {
          tagStatus   = "untagged"
          countType   = local.lifecycle_rules.untagged_images.count_type
          countUnit   = local.lifecycle_rules.untagged_images.count_unit
          countNumber = local.lifecycle_rules.untagged_images.count_number
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ============================================
# Repository Policies (Cross-Account Access)
# ============================================

resource "aws_ecr_repository_policy" "this" {
  for_each   = local.cross_account_access_enabled ? aws_ecr_repository.this : {}
  repository = each.value.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountPull"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_principals
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:DescribeRepositories",
          "ecr:DescribeImages",
          "ecr:ListImages"
        ]
      }
    ]
  })
}

# ============================================
# Registry Scanning Configuration (Optional)
# ============================================

resource "aws_ecr_registry_scanning_configuration" "this" {
  count = var.enable_enhanced_scanning ? 1 : 0

  scan_type = "ENHANCED"

  rule {
    scan_frequency = "SCAN_ON_PUSH"
    repository_filter {
      filter      = "${var.project_name}-*"
      filter_type = "WILDCARD"
    }
  }
}

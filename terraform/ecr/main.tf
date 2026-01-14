# ============================================
# ECR Repositories - Core Resources
# ============================================

resource "aws_ecr_repository" "this" {
  for_each = local.repositories_with_full_names

  name                 = each.value.name
  image_tag_mutability = var.image_tag_mutability

  # Enable image scanning on push
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  # Encryption configuration
  encryption_configuration {
    encryption_type = var.enable_encryption ? "KMS" : "AES256"
    kms_key         = var.enable_encryption && var.kms_key_arn != null ? var.kms_key_arn : null
  }

  # Force deletion during destroy (for dev/test environments)
  force_delete = var.environment != "prod" ? true : false

  tags = merge(
    local.common_tags,
    {
      Name        = each.value.name
      Description = each.value.description
      Application = each.value.short_name
    }
  )
}

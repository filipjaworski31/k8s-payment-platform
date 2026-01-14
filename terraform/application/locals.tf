# ============================================
# Local Values & Computed Variables
# ============================================

locals {
  # Common tags to apply to all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps Team"
    CostCenter  = "Engineering"
  }

  # Repository naming convention
  repositories_with_full_names = {
    for k, v in var.repositories : k => {
      name        = "${var.project_name}-${v.name}"
      description = v.description
      short_name  = v.name
    }
  }

  # Lifecycle policy rules as reusable data structure
  lifecycle_rules = {
    tagged_images = {
      priority     = 1
      description  = "Keep last ${var.image_retention_count} tagged images"
      tag_prefixes = ["v", "release", "main", "develop", "prod", "staging"]
      count_type   = "imageCountMoreThan"
      count_number = var.image_retention_count
    }
    untagged_images = {
      priority     = 2
      description  = "Remove untagged images older than ${var.untagged_image_retention_days} days"
      count_type   = "sinceImagePushed"
      count_unit   = "days"
      count_number = var.untagged_image_retention_days
    }
  }

  # Cross-account access enabled flag
  cross_account_access_enabled = length(var.allowed_principals) > 0
}

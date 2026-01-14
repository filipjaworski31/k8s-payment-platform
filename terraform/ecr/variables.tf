# ============================================
# AWS & Project Configuration
# ============================================

variable "aws_region" {
  description = "AWS region for ECR repositories"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "finpay-payment-platform"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

# ============================================
# ECR Repository Configuration
# ============================================

variable "repositories" {
  description = "Map of ECR repository configurations"
  type = map(object({
    name        = string
    description = string
  }))
  default = {
    payment_api = {
      name        = "payment-api"
      description = "Payment API - REST API for payment processing"
    }
    payment_worker = {
      name        = "payment-worker"
      description = "Payment Worker - Background payment processor"
    }
  }
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be either MUTABLE or IMMUTABLE"
  }
}

# ============================================
# Security Configuration
# ============================================

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "enable_enhanced_scanning" {
  description = "Enable AWS ECR enhanced scanning (additional cost)"
  type        = bool
  default     = false
}

variable "enable_encryption" {
  description = "Enable encryption for images using KMS"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of KMS key for ECR encryption (optional, uses AWS managed key if not provided)"
  type        = string
  default     = null
}

variable "allowed_principals" {
  description = "List of AWS principals (account IDs or ARNs) allowed to pull images"
  type        = list(string)
  default     = []
}

# ============================================
# Lifecycle Policy Configuration
# ============================================

variable "image_retention_count" {
  description = "Number of tagged images to retain in the repository"
  type        = number
  default     = 10

  validation {
    condition     = var.image_retention_count >= 1 && var.image_retention_count <= 100
    error_message = "image_retention_count must be between 1 and 100"
  }
}

variable "untagged_image_retention_days" {
  description = "Number of days to retain untagged images"
  type        = number
  default     = 7

  validation {
    condition     = var.untagged_image_retention_days >= 1 && var.untagged_image_retention_days <= 365
    error_message = "untagged_image_retention_days must be between 1 and 365"
  }
}

# ============================================
# Monitoring Configuration
# ============================================

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for ECR scan results"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a valid CloudWatch retention period"
  }
}

variable "enable_vulnerability_alarms" {
  description = "Enable CloudWatch alarms for high vulnerability counts"
  type        = bool
  default     = false
}

variable "vulnerability_alarm_threshold" {
  description = "Threshold for high severity vulnerability alarm"
  type        = number
  default     = 5
}

variable "enable_cloudwatch_dashboard" {
  description = "Enable CloudWatch dashboard for ECR metrics"
  type        = bool
  default     = false
}

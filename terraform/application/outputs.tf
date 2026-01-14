# ============================================
# ECR Repository Outputs
# ============================================

output "repository_urls" {
  description = "Map of ECR repository URLs"
  value = {
    for k, repo in aws_ecr_repository.this : k => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of ECR repository ARNs"
  value = {
    for k, repo in aws_ecr_repository.this : k => repo.arn
  }
}

output "repository_registry_ids" {
  description = "Map of ECR repository registry IDs"
  value = {
    for k, repo in aws_ecr_repository.this : k => repo.registry_id
  }
}

# Individual repository outputs for easy reference
output "payment_api_repository_url" {
  description = "Payment API ECR repository URL"
  value       = aws_ecr_repository.this["payment_api"].repository_url
}

output "payment_worker_repository_url" {
  description = "Payment Worker ECR repository URL"
  value       = aws_ecr_repository.this["payment_worker"].repository_url
}

# Registry information
output "ecr_registry_url" {
  description = "ECR registry URL"
  value       = split("/", aws_ecr_repository.this["payment_api"].repository_url)[0]
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = var.aws_region
}

# Login command helper
output "docker_login_command" {
  description = "Command to authenticate Docker with ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${split("/", aws_ecr_repository.this["payment_api"].repository_url)[0]}"
}

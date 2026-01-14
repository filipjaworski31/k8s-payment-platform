output "github_actions_role_arn" {
  description = "ARN of IAM role for GitHub Actions"
  value       = aws_iam_role.github_actions_ecr.arn
}

output "oidc_provider_arn" {
  description = "ARN of GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "setup_instructions" {
  description = "Instructions for GitHub Secrets setup"
  value       = <<-EOT
  
  ====================================
  GitHub Secrets Setup
  ====================================
  
  Add these secrets to your GitHub repository:
  
  1. AWS_ACCOUNT_ID
     Value: ${data.aws_caller_identity.current.account_id}
  
  2. AWS_ROLE_ARN
     Value: ${aws_iam_role.github_actions_ecr.arn}
  
  Go to: Settings → Secrets and variables → Actions → New repository secret
  
  ====================================
  EOT
}

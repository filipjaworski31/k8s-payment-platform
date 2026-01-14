# Bootstrap Layer - IAM & OIDC

This layer creates the foundational AWS resources needed for GitHub Actions CI/CD.

## ⚠️ IMPORTANT

**This layer should NEVER be destroyed through CI/CD!**

Destroying these resources will break GitHub Actions authentication.

## Resources Created

- GitHub OIDC Provider
- IAM Role for GitHub Actions
- ECR access policies

## Manual Deployment

### Prerequisites
```bash
# Configure AWS credentials
aws configure
```

### Deploy
```bash
cd terraform/bootstrap

# Create terraform.tfvars
cat > terraform.tfvars << EOF
github_org  = "YOUR_GITHUB_ORG"
github_repo = "YOUR_REPO_NAME"

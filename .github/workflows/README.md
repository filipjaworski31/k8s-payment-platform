# GitHub Actions Workflows

This directory contains CI/CD workflows for the FinPay Payment Platform.

## Workflows

### 1. `docker-build-scan-push.yml` (Main CI/CD)

**Purpose:** Build, scan, and push Docker images to AWS ECR

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Manual dispatch

**Jobs:**
1. **build-scan-api:** Build and scan payment-api image
2. **build-scan-worker:** Build and scan payment-worker image
3. **push-to-ecr:** Push images to AWS ECR (only on main/develop)

**Requirements:**
- CRITICAL vulnerabilities = 0 (hard requirement)
- HIGH vulnerabilities logged but not blocking

**Secrets Required:**
- `AWS_ACCOUNT_ID`: AWS account ID for ECR
- `AWS_ROLE_ARN`: IAM role ARN for OIDC authentication

### 2. `terraform-validate.yml`

**Purpose:** Validate Terraform configuration

**Triggers:**
- Changes to `terraform/**` directory
- Pull requests

**Jobs:**
- Terraform format check
- Terraform initialization
- Terraform validation

### 3. `security-scan.yml`

**Purpose:** Daily security scanning

**Triggers:**
- Daily schedule (2 AM UTC)
- Manual dispatch

**Jobs:**
- Filesystem vulnerability scanning
- Upload results to GitHub Security tab

## Setup Instructions

### 1. Configure AWS OIDC

Create an OIDC provider in AWS IAM:
```bash
# Get GitHub OIDC thumbprint
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 2. Create IAM Role for GitHub Actions
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
```

### 3. Attach ECR Policy to Role
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:DescribeImages"
      ],
      "Resource": "*"
    }
  ]
}
```

### 4. Add GitHub Secrets

Go to repository Settings → Secrets and variables → Actions:

- `AWS_ACCOUNT_ID`: Your AWS account ID (e.g., 123456789012)
- `AWS_ROLE_ARN`: ARN of the IAM role created above

## Image Tagging Strategy

### Main Branch
- Format: `v1.0.{RUN_NUMBER}`
- Example: `v1.0.42`
- Also tagged as `latest`

### Develop Branch
- Format: `dev-{RUN_NUMBER}`
- Example: `dev-42`

### Pull Requests
- Format: `pr-{PR_NUMBER}`
- Example: `pr-123`
- Not pushed to ECR

## Vulnerability Scanning

### Critical Vulnerabilities
- **Action:** Build fails immediately
- **Severity:** CRITICAL
- **Threshold:** 0 (zero tolerance)

### High Vulnerabilities
- **Action:** Logged but not blocking
- **Severity:** HIGH
- **Threshold:** Warning only

## Artifacts

Build artifacts are retained for 1 day:
- `payment-api-image.tar.gz`
- `payment-worker-image.tar.gz`

## GitHub Actions Cache

Docker layer caching is enabled:
- **Cache key:** GitHub Actions cache
- **Mode:** max (cache all layers)
- **Benefit:** Faster subsequent builds

## Manual Deployment

Trigger manual deployment:
```bash
# Via GitHub UI
Actions → Docker Build, Scan & Push → Run workflow

# Or via GitHub CLI
gh workflow run docker-build-scan-push.yml \
  --ref main \
  -f environment=prod
```

## Monitoring

Check workflow status:
- GitHub Actions tab in repository
- Job summaries include:
  - Trivy scan results
  - Deployment summaries
  - Image tags and pull commands

## Troubleshooting

### Build Fails on Trivy Scan
```bash
# Run locally to debug
docker build -f Dockerfile.api -t payment-api:debug .
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image payment-api:debug
```

### AWS Authentication Fails
- Verify OIDC provider is configured
- Check IAM role trust policy
- Ensure secrets are set correctly
- Verify role has ECR permissions

### Push to ECR Fails
- Ensure ECR repositories exist (run Terraform)
- Check IAM role permissions
- Verify AWS_ACCOUNT_ID secret

## Best Practices

1. ✅ Always scan before push
2. ✅ Use OIDC instead of long-lived credentials
3. ✅ Tag images semantically
4. ✅ Keep artifacts for short period (1 day)
5. ✅ Enable Docker layer caching
6. ✅ Use job outputs for data passing
7. ✅ Generate deployment summaries
8. ✅ Fail fast on CRITICAL vulnerabilities

---

**Maintained by:** FinPay DevOps Team

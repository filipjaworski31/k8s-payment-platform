# GitHub Secrets Configuration

## Required Secrets

Add these secrets to your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

### 1. AWS_ACCOUNT_ID

Your AWS account ID (12-digit number)

**Example:** `123456789012`

**How to find:**
```bash
aws sts get-caller-identity --query Account --output text
```

### 2. AWS_ROLE_ARN

ARN of the IAM role for GitHub Actions OIDC

**Format:** `arn:aws:iam::ACCOUNT_ID:role/GitHubActionsRole`

**Example:** `arn:aws:iam::123456789012:role/GitHubActionsECRRole`

---

## AWS OIDC Setup (One-time)

### Step 1: Create OIDC Provider
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### Step 2: Create IAM Role

**Trust Policy** (`trust-policy.json`):
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
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
```

**Create role:**
```bash
aws iam create-role \
  --role-name GitHubActionsECRRole \
  --assume-role-policy-document file://trust-policy.json
```

### Step 3: Attach ECR Policy

**ECR Policy** (`ecr-policy.json`):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeRepositories",
        "ecr:DescribeImages",
        "ecr:ListImages"
      ],
      "Resource": [
        "arn:aws:ecr:us-east-1:ACCOUNT_ID:repository/finpay-payment-platform-payment-api",
        "arn:aws:ecr:us-east-1:ACCOUNT_ID:repository/finpay-payment-platform-payment-worker"
      ]
    }
  ]
}
```

**Attach policy:**
```bash
aws iam put-role-policy \
  --role-name GitHubActionsECRRole \
  --policy-name ECRAccessPolicy \
  --policy-document file://ecr-policy.json
```

### Step 4: Get Role ARN
```bash
aws iam get-role \
  --role-name GitHubActionsECRRole \
  --query Role.Arn \
  --output text
```

Copy this ARN and add it as `AWS_ROLE_ARN` secret in GitHub.

---

## Verification

Test the setup:

1. Push to `develop` branch
2. Go to Actions tab in GitHub
3. Watch workflow execute
4. Verify:
   - ✅ Docker builds succeed
   - ✅ Trivy scans pass (0 CRITICAL)
   - ✅ Images pushed to ECR

---

## Security Notes

- ✅ No long-lived credentials in GitHub
- ✅ OIDC tokens are short-lived (1 hour)
- ✅ Role can only be assumed by your repo
- ✅ Principle of least privilege (ECR only)

---

**Setup Time:** ~10 minutes

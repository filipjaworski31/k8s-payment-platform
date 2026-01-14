# AWS ECR Infrastructure for Payment Platform

This Terraform configuration creates AWS ECR repositories for the FinPay Payment Platform.

## Resources Created

- **ECR Repositories:** 2 (payment-api, payment-worker)
- **Lifecycle Policies:** Automatic cleanup of old images
- **Image Scanning:** Enabled on push
- **Encryption:** KMS encryption (AES256 by default)
- **CloudWatch Logs:** Scan results logging

## Prerequisites

1. AWS CLI configured with credentials
2. Terraform >= 1.6.0 installed
3. Appropriate AWS permissions (ECR, CloudWatch)

## Usage

### Initialize Terraform
```bash
cd terraform/ecr
terraform init
```

### Plan Infrastructure
```bash
terraform plan
```

### Apply Infrastructure
```bash
terraform apply
```

### Destroy Infrastructure (when needed)
```bash
terraform destroy
```

## Configuration

### Variables

Key variables in `variables.tf`:

- `aws_region`: AWS region (default: us-east-1)
- `project_name`: Project name prefix
- `environment`: Environment name (dev/staging/prod)
- `image_retention_count`: Number of images to keep (default: 10)
- `scan_on_push`: Enable vulnerability scanning (default: true)

### Custom Configuration

Create `terraform.tfvars`:
```hcl
aws_region              = "us-east-1"
environment             = "dev"
image_retention_count   = 15
scan_on_push            = true
enable_encryption       = true
```

## Outputs

After applying, Terraform outputs:

- Repository URLs (for docker push)
- Repository ARNs
- Docker login command
- AWS Account ID and Region

### Example Output
```
payment_api_repository_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com/finpay-payment-platform-payment-api"
payment_worker_repository_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com/finpay-payment-platform-payment-worker"
docker_login_command = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com"
```

## Docker Usage

### Authenticate with ECR
```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com
```

### Tag Images
```bash
docker tag payment-api:local <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/finpay-payment-platform-payment-api:v1.0.0
docker tag payment-worker:local <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/finpay-payment-platform-payment-worker:v1.0.0
```

### Push Images
```bash
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/finpay-payment-platform-payment-api:v1.0.0
docker push <ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/finpay-payment-platform-payment-worker:v1.0.0
```

## Lifecycle Policies

Images are automatically cleaned up based on:

1. **Tagged Images:** Keep last 10 images with tags (v*, release*, main*, develop*)
2. **Untagged Images:** Remove after 7 days

Adjust in `variables.tf`:
- `image_retention_count`
- `untagged_image_retention_days`

## Security Features

- ✅ Image scanning on push
- ✅ KMS encryption at rest
- ✅ IAM-based access control
- ✅ CloudWatch logging for scan results
- ✅ Lifecycle policies for cleanup

## Cost Optimization

- Lifecycle policies reduce storage costs
- Scan results logged to CloudWatch (30-day retention)
- Encryption uses AWS managed keys by default (no KMS charges)

## Best Practices Implemented

1. **Immutable Tags:** Can be enabled via `image_tag_mutability = "IMMUTABLE"`
2. **Automated Scanning:** Vulnerabilities detected on push
3. **Retention Policies:** Automatic cleanup of old/unused images
4. **Encryption:** All images encrypted at rest
5. **Cross-Account Access:** Configurable via `allowed_principals`

## Integration with CI/CD

These repositories are designed to work with:
- GitHub Actions workflows
- GitLab CI pipelines
- AWS CodePipeline
- Jenkins

See `.github/workflows/` for GitHub Actions examples.

## Troubleshooting

### Authentication Issues
```bash
# Re-authenticate with ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <REGISTRY_URL>
```

### Permission Errors

Ensure IAM user/role has:
- `ecr:GetAuthorizationToken`
- `ecr:BatchCheckLayerAvailability`
- `ecr:PutImage`
- `ecr:InitiateLayerUpload`
- `ecr:UploadLayerPart`
- `ecr:CompleteLayerUpload`

## Maintenance

### Update Images
```bash
# Pull latest changes
terraform plan

# Apply updates
terraform apply
```

### Monitor Costs
```bash
# Check ECR usage
aws ecr describe-repositories --region us-east-1
aws cloudwatch get-metric-statistics --namespace AWS/ECR --metric-name RepositoryStorageUtilization
```

## Support

For issues or questions:
- Review AWS ECR documentation
- Check CloudWatch logs for scan results
- Verify IAM permissions


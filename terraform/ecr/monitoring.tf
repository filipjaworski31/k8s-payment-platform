# ============================================
# CloudWatch Monitoring & Logging
# ============================================

# Log Group for ECR scan results
resource "aws_cloudwatch_log_group" "ecr_scan_results" {
  count = var.enable_cloudwatch_logs ? 1 : 0

  name              = "/aws/ecr/${var.project_name}/scan-results"
  retention_in_days = var.log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-ecr-scan-logs"
    }
  )
}

# CloudWatch Metric Alarm - High vulnerability count
resource "aws_cloudwatch_metric_alarm" "high_vulnerabilities" {
  for_each = var.enable_vulnerability_alarms ? aws_ecr_repository.this : {}

  alarm_name          = "${each.value.name}-high-vulnerabilities"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HighSeverityVulnerabilityCount"
  namespace           = "AWS/ECR"
  period              = 300
  statistic           = "Maximum"
  threshold           = var.vulnerability_alarm_threshold
  alarm_description   = "Alert when high severity vulnerabilities detected in ${each.value.name}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    RepositoryName = each.value.name
  }

  tags = local.common_tags
}

# CloudWatch Dashboard for ECR metrics (optional)
resource "aws_cloudwatch_dashboard" "ecr" {
  count = var.enable_cloudwatch_dashboard ? 1 : 0

  dashboard_name = "${var.project_name}-ecr-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            for k, repo in aws_ecr_repository.this : [
              "AWS/ECR",
              "RepositoryPullCount",
              {
                stat   = "Sum"
                period = 300
              },
              {
                RepositoryName = repo.name
              }
            ]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "ECR Pull Counts"
        }
      }
    ]
  })
}

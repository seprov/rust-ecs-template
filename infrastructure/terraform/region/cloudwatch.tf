resource "aws_cloudwatch_log_group" "rq" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 30  # Adjust this value as needed
}

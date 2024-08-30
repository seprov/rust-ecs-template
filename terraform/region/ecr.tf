resource "aws_ecr_repository" "rq" {
  name = "${var.app_name}-repo"
}

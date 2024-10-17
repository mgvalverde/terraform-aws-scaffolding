resource "aws_ecr_repository" "this" {
  name = var.ecr_repo_name
}

resource "aws_ssm_parameter" "this" {
  name  = "/${var.owner}/${var.project}/${var.environment}/ecr/url"
  type  = "String"
  value = aws_ecr_repository.this.repository_url
}

output "aws_ecr_repository_uri" {
  description = "ECR repository URL"
  value = aws_ecr_repository.this.repository_url
}


output "aws_ssm_ecr_lambda_url" {
  description = "SSM parameter to retrieve the ECR repository URL"
  value = aws_ssm_parameter.this.name
}
data "aws_ssm_parameter" "uri" {
  name = var.lambda_image_uri_ssm
}

module "lambda_vector" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.13.0"

  create_function = true
  publish = true

  # Lambda configuration
  package_type  = "Image"
  image_uri      = data.aws_ssm_parameter.uri.value
  architectures = ["x86_64"]
  create_package = false

  runtime       = var.runtime
  function_name = "${local.app_preffix}-lambda"
  description   = coalesce(null,"")
  handler       = var.handler

  timeout = var.timeout
  memory_size = var.memory_size


  ## Envvar configuration
  environment_variables = var.environment_variables

  # Permissions
  create_role = true

}

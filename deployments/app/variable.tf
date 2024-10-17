variable "region" {
  description = "AWS default region"
  type        = string
  default     = null
}
variable "owner" {
  description = "Project owner"
  type        = string
}
variable "project" {
  description = "Project Id"
  type        = string
}
variable "environment" {
  description = "Project environment"
  type        = string
}
variable "extra_tags" {
  description = "Tags"
  type = map(string)
  default = {}
}

variable "runtime" {
  description = ""
  type        = string
  default     = "python3.12"
}
variable "description" {
  description = ""
  type        = string
  default     = "Pending descr"
}
variable "handler" {
  description = ""
  type        = string
  default     = "index.handler"
}
variable "timeout" {
  description = ""
  type        = number
  default     = 30
}
variable "memory_size" {
  description = ""
  type        = number
  default     = 128
}
variable "environment_variables" {
  description = ""
  type = map(string)
  default = {}
}
variable "lambda_image_uri_ssm" {
  description = ""
  type        = string
}

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
  type        = map(string)
  default = {}
}
variable "ecr_repo_name" {
  description = "Repository name"
}
variable "runtime" {
  description = ""
  type = string
  default = ""
}
variable "description" {
  description = ""
  type = string
  default = ""
}
variable "handler" {
  description = ""
  type = string
  default = "index.handler"
}
variable "timeout" {
  description = ""
  type = number
  default = 30
}
variable "memory_size" {
  description = ""
  type = number
  default = 128
}
variable "environment_variables" {
  description = ""
  type = map(string)
  default = {  }
}

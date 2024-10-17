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
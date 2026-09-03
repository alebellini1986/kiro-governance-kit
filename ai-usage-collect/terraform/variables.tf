variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "Prod"
}

variable "region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "eu-west-1"
}

variable "account_id" {
  description = "AWS account ID for the your-aws-profile account"
  type        = string
}

variable "api_key_value" {
  description = "API key value for the usage collection endpoint"
  type        = string
  sensitive   = true
}

variable "project_tag" {
  description = "Project tag for resource tagging"
  type        = string
  default     = "AI"
}

variable "owner_tag" {
  description = "Owner tag for resource tagging"
  type        = string
  default     = "Your Team"
}

variable "cost_center_tag" {
  description = "Cost center tag for resource tagging"
  type        = string
  default     = "YOUR_COST_CENTER"
}

provider "aws" {
  region  = var.region
  profile = "your-aws-profile"

  default_tags {
    tags = {
      Project     = var.project_tag
      Environment = var.environment
      Owner       = var.owner_tag
      CostCenter  = var.cost_center_tag
      Application = "Kiro"
      Brand       = "Core"
    }
  }
}

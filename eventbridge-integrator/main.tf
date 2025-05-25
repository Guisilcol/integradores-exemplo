terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "eventbridge_rules" {
  source = "./modules/eventbridge_rules"

  rules_directory = var.rules_directory
  event_bus_name  = var.event_bus_name
  role_arn        = var.eventbridge_role_arn
  enabled         = var.rules_enabled_by_default
  account_id      = var.account_id
}

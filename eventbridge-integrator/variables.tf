variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "account_id" {
  type = string
}

variable "rules_directory" {
  type    = string
  default = "./rules"
}

variable "event_bus_name" {
  type    = string
  default = "default"
}

variable "eventbridge_role_arn" {
  type = string
}

variable "rules_enabled_by_default" {
  type    = bool
  default = true
}

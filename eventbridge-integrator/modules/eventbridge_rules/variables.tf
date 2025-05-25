variable "rules_directory" {
  type = string
}

variable "event_bus_name" {
  type    = string
  default = "default"
}

variable "role_arn" {
  type = string
}

variable "enabled" {
  type    = bool
  default = true
}

variable "account_id" {
  type = string
}

variable "east_region" {
  type    = string
  default = "us-east-1"
}

variable "west_region" {
  type    = string
  default = "us-west-1"
}

variable "log_retention_days" {
  type    = number
  default = 7
}

variable "schedule_expression" {
  type        = string
  default     = "rate(6 hours)"
  description = "EventBridge schedule expression for the record reaper (e.g. 'rate(1 hour)', 'rate(30 minutes)')"
}

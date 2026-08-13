variable "east_region" {
  type    = string
  default = "us-east-1"
}

variable "west_region" {
  type    = string
  default = "us-west-1"
}

variable "schedule_expression" {
  type        = string
  default     = "rate(1 hour)"
  description = "EventBridge schedule expression for the record reaper (e.g. 'rate(1 hour)', 'rate(30 minutes)')"
}

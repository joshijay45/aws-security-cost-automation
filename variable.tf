variable "aws_region" {
  description = "AWS region to deploy security automation"
  type = string
  default = "us-east-1"
}

variable "enviornment" {
  description = "project enviornment"
  type = string
  default = "security"
}

variable "project_name" {
  description = "Security-automation"
  type = string
  default = "security_automation"
}

variable "security_email" {
  description = "Emial that will recieve security alert"
  type = string
  default = "jayjoshi45264@gmail.com"
}
resource "aws_sns_topic" "security_alerts" {
  name = "${var.project_name}_alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol = "email"
  endpoint = var.security_email
}
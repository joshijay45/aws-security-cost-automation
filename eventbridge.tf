resource "aws_cloudwatch_event_rule" "s3_creation_rule" {
  name = "${var.project_name}-s3-creation-rule"
  description = "Triggers when a new s3 bucket is created"
  event_pattern = jsonencode({
    source = ["aws.s3"]
    detail-type =  ["AWS API Call via CloudTrail"]
    detail = {eventSource = ["s3.amazonaws.com"]
    eventName = ["CreateBucket"]}
  })
}

resource "aws_cloudwatch_event_target" "trigger_lambda" {
  rule = aws_cloudwatch_event_rule.s3_creation_rule.name 
  target_id = "SendToLambda"
  arn = aws_lambda_function.security_guard.arn
}


resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id = "AllowExecutionFromEventBridge"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.security_guard.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.s3_creation_rule.arn
}

resource "aws_cloudwatch_event_rule" "ec2_schedule" {
  name = "${var.project_name}-ece-schedule"
  description = "Triggers lambda every hour to check for idle ec2 instance"
  schedule_expression = "rate(1 hour)"
}

resource "aws_cloudwatch_event_target" "target_lambda_ec2" {
  rule = aws_cloudwatch_event_rule.ec2_schedule.name
  target_id = "SendToLambdaEC2"
  arn = aws_lambda_function.security_guard.arn
}

resource "aws_lambda_permission" "allow_eventbridge_ec2" {
  statement_id =  "AllowExecutionFromEventBridgeEC2"
  action = "lambda:Invokefunction"
  function_name = aws_lambda_function.security_guard.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.ec2_schedule.arn
}
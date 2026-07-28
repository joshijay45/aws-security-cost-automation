data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/fixer.zip"
}

resource "aws_lambda_function" "security_guard" {
  filename      = data.archive_file.lambda_zip.output_path
  function_name = "${var.project_name}-guard"
  role          = aws_iam_role.lambda_security_role.arn
  handler       = "fixer.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Passing SNS topic ARN into python scripts 
  environment {
    variables = {
        SNS_TOPIC_ARN = aws_sns_topic.security_alerts.arn
    }
  }
}
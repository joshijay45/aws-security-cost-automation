# Trust policy that allows lambda to assume IAM role 

data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    actions = [ "sts:AssumeRole" ]
    principals {
      type = "Service"
      identifiers = [ "lambda.amazonaws.com" ]
    }
  }
}

resource "aws_iam_role" "lambda_security_role" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = aws_iam_role.lambda_security_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_s3_sns_policy" {
  description = "Gives permission to lambda to encrypt s3 and send emails"
  name = "${var.project_name}-lambda-action-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = ["s3:PutEncryptionConfiguration", "s3:GetEncryptionConfiguration"]
      Effect ="Allow"
      Resource = "arn:aws:s3:::*"
    },
    {
    Action = "sns:Publish"
    Effect = "Allow"
    Resource = aws_sns_topic.security_alerts.arn
    }
]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_sns_policy_attach" {
  role = aws_iam_role.lambda_security_role.name 
  policy_arn =  aws_iam_policy.lambda_s3_sns_policy.arn
}

data "aws_iam_policy_document" "lambda_action_ec2" {
  statement {
    sid = "AllowC2AndCloudWatch"
    effect = "Allow"
    actions = [ "ec2:DescribeInstances","ec2:StopInstances","cloudwatch:GetMetricStatistics" ]
    resources = [ "*" ]
  }
}

resource "aws_iam_policy" "lambda_action_policy" {
  name = "${var.project_name}-action_policy"
  description = "Allow lambda to stop idle ec2 instance"
  policy = data.aws_iam_policy_document.lambda_action_ec2.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attch" {
  role       = aws_iam_role.lambda_security_role.name
  policy_arn = aws_iam_policy.lambda_action_policy.arn
}
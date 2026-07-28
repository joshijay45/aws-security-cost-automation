resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "security-automation-bucket-cloudtrail-logs"
  force_destroy = true
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "cloudtrail_policy_doc" {
  statement {
    sid = "AllowCloudTrailToCheckAccess"
    effect = "Allow"
    actions = ["s3:GetBucketAcl"]
    resources =  [aws_s3_bucket.cloudtrail_logs.arn ]
    principals {
      type = "Service"
      identifiers = [ "cloudtrail.amazonaws.com" ]
    }
  }
  statement {
    sid = "AllowCloudTrailToWriteLogs"
    effect = "Allow"
    actions = [ "s3:PutObject" ]
    resources = ["${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    principals {
      type = "Service"
      identifiers = [ "cloudtrail.amazonaws.com" ]

    }
    condition {
      test = "StringEquals"
      variable = "s3:x-amz-acl"
       values   = ["bucket-owner-full-control"]
    }

  }
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_policy_doc.json
}

resource "aws_cloudtrail" "security_trail" {
  name = "${var.project_name}-trail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail = true
  enable_log_file_validation = true

  depends_on = [ aws_s3_bucket_policy.cloudtrail_policy ]
}
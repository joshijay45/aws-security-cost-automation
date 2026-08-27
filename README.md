# AWS Event-Driven Security & Cost Optimization

# What is this project?

Architected this automated security & cost optimization system to keep an AWS environment secure and cost-efficient. Instead of relying on engineers to manually check settings every day, these serverless Python scripts monitor the account 24/7 and take instant remediation actions when necessary.

Everything is provisioned and deployed automatically using Terraform.

# How It Works

1. The Security Guard :

The Problem: Developers sometimes accidentally create S3 Buckets without enabling encryption, leaving company data unprotected.

The Trigger: AWS CloudTrail monitors API calls and detects the unencrypted bucket creation. It forwards this event to Amazon EventBridge, which immediately triggers a Lambda function.

The Action: The Python script instantly enforces AES-256 encryption on the bucket and pushes an alert to the security team via Amazon SNS.

2. The Money Saver :

The Problem: Virtual machines (EC2 instances) are often left running overnight or over the weekend, racking up unnecessary cloud bills.

The Trigger: An Amazon EventBridge cron schedule wakes up a Lambda function every hour.

The Action: The script queries CloudWatch for CPU metrics across all running servers. If it finds a server sitting idle (under 5% CPU usage) for the last hour, it safely powers it down and emails the FinOps team with a cost-savings report.

# Tech Stack Used

Infrastructure as Code: Terraform

Code: Python 3 (Boto3 Library)

AWS Services: Lambda, EventBridge, CloudTrail, EC2, S3, SNS 

# How to Deploy

Clone this repository:
git clone https://github.com/joshijay45/aws-security-cost-automation.git

Open the variables.tf file and update it with your email address to receive the alerts.

Run terraform init to download the required providers.

Run terraform apply -auto-approve to launch the automation.

To test: Create a new S3 bucket in your account without encryption, and watch your email for the instant remediation alert.
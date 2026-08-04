# AWS Event-Driven Security & Cost Optimization Automation:

This project is an automated "watchdog" for an AWS Cloud environment. It uses Python and AWS Lambda to automatically fix security mistakes and save money by turning off unused servers.

Instead of a human manually checking settings every day, this serverless bot monitors the account 24/7 and takes action instantly. Everything is built and deployed automatically using Terraform.

# How It Works :

The Security Guard (Instant Fixes):

The Problem: Sometimes developers accidentally create cloud storage folders (S3 Buckets) without turning on encryption, leaving data unprotected.

The Fix: AWS CloudTrail acts like a security camera and sees the bucket being created. It tells Amazon EventBridge to wake up our AWS Lambda.

The Action: The bot instantly turns on AES-256 encryption for the bucket and sends an email alert to the security team via Amazon SNS.

2. The Money Saver (Hourly Checks):

The Problem: People often forget to turn off their virtual computers (EC2 instances) before going home, which costs the company money.

The Fix: Every hour, a timer wakes up the Python bot.

The Action: The bot checks the CPU usage of all running servers. If a server has been sitting idle (under 5% CPU) for the last hour, the bot automatically shuts it down and emails the finance (FinOps) team with the money-saving alert.

# Tech Stack Used:

Infrastructure as code: Terraform

Code: Python 3 (Boto3 Library)

AWS Services: Lambda (The Bot), EventBridge (The Triggers), CloudTrail (The Tracker), EC2 (Servers), S3 (Storage), SNS (Email Alerts).

# How to Deploy:

Clone this repository

git clone [https://github.com/joshijay45/aws-security-cost-automation.git]

Open the variables.tf file and add your email address to receive the alerts.

Run terraform init to download the plugins.

Run terraform apply -auto-approve to launch the bot.

Create an S3 bucket without encryption and watch your email for the instant fix alert!
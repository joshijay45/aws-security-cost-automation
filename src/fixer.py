from datetime import datetime, timedelta, timezone
import json
import boto3
import os

s3 = boto3.client('s3')
sns = boto3.client('sns')
cw = boto3.client('cloudwatch')
ec2 = boto3.client('ec2')
def lambda_handler(event, context):
    source = event.get('source')

    if source == 'aws.s3':
        detail = event.get('detail', {})
        req_params = detail.get('requestParameters')

        if req_params and 'bucketName' in req_params:
            bucket_name = req_params['bucketName']
        else:
            bucket_name = event['detail']['requestParameters']['bucketName']

        s3.put_bucket_encryption(
            Bucket=bucket_name,
            ServerSideEncryptionConfiguration={
                'Rules': [
                    {
                        'ApplyServerSideEncryptionByDefault': {
                            'SSEAlgorithm': 'AES256'
                        }
                    }
                ]
            }
        )
        sns.publish(
            TopicArn=os.environ['SNS_TOPIC_ARN'],
            Subject="AWS security alert: bucket encrypted",
            Message=(
                f"Alert: The new S3 bucket '{bucket_name}' was created without encryption, "
                "and we have successfully secured it with AES256 encryption."
            )
        )
        
        return "Action complete: Bucket secured and team alerted."

    if source == 'aws.events':
        stopped = []
        now = datetime.now(timezone.utc)
        one_hour_ago = now - timedelta(hours=1)
        instances = ec2.describe_instances(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
        
        for res in instances['Reservations']:
            for inst in res['Instances']:
                iid = inst['InstanceId']
                metrics = cw.get_metric_statistics(
                    Namespace='AWS/EC2', MetricName='CPUUtilization',
                    Dimensions=[{'Name': 'InstanceId', 'Value': iid}],
                    StartTime=one_hour_ago, 
                    EndTime=now,
                    Period=3600, 
                    Statistics=['Average']
                )
                
                if metrics['Datapoints'] and metrics['Datapoints'][0]['Average'] < 5.0:
                    ec2.stop_instances(InstanceIds=[iid])
                    stopped.append(iid)

        if stopped:
            sns.publish(
                TopicArn=os.environ['SNS_TOPIC_ARN'],
                Subject="FinOps Alert",
                Message=f"Stopped idle EC2s: {stopped}"
            )
        return "EC2 Checked"
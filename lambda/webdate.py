#!/usr/bin/python3

from datetime import datetime
import boto3
import os


def lambda_handler(event,context):
    content = datetime.now().strftime("%m/%d/%Y %H:%M:%S")
    bucket = os.environ.get('BUCKET')
    
    client = boto3.client('s3')
    client.put_object(
        Body=content,
        Bucket=bucket,
        Key='index.html')


    return {
        'statusCode': 200,
        'body': 'Success!'
        }

if __name__ == "__main__":
  lambda_handler('','')
  
  

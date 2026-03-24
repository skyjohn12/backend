"""
Lambda Function: SNS Message Handler
Triggered by SNS notification - demonstrates event-driven serverless architecture
"""

import json
import boto3 # type: ignore
from datetime import datetime

# Initialize AWS clients
dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

def lambda_handler(event, context):
    """
    Lambda function triggered by SNS topic
    Processes the notification and stores data
    """
    
    print(f"Lambda function triggered at {datetime.now().isoformat()}")
    print(f"Event: {json.dumps(event)}")
    
    # Extract SNS message
    for record in event['Records']:
        if 'Sns' in record:
            sns_message = record['Sns']
            message = sns_message['Message']
            subject = sns_message.get('Subject', 'No Subject')
            timestamp = sns_message['Timestamp']
            
            print(f"Received SNS message: {subject}")
            print(f"Message content: {message}")
            
            # Process the message
            result = {
                'statusCode': 200,
                'body': json.dumps({
                    'message': 'SNS notification processed successfully',
                    'subject': subject,
                    'received_at': timestamp,
                    'processed_at': datetime.now().isoformat(),
                    'service_type': 'PaaS - AWS Lambda + SNS',
                    'trigger': 'SNS Topic'
                })
            }
            
            print(f"Processing completed: {result}")
            
            # Optional: Send message to SQS for further processing
            # Only forward if this is NOT already a processed message from SQS (avoid loops)
            try:
                # Get SQS queue URL from environment variable
                import os
                queue_url = os.environ.get('SQS_QUEUE_URL')
                
                # Check if message is already from SQS processor (avoid recursive loop)
                if queue_url and subject != 'SQS Message Processed':
                    # Truncate message if too large to prevent recursive bloat
                    truncated_message = message[:500] if len(message) > 500 else message
                    
                    sqs.send_message(
                        QueueUrl=queue_url,
                        MessageBody=json.dumps({
                            'source': 'sns-lambda',
                            'original_message': truncated_message,
                            'subject': subject,
                            'timestamp': datetime.now().isoformat(),
                            'truncated': len(message) > 500
                        })
                    )
                    print(f"Message forwarded to SQS queue (size: {len(message)} chars)")
                elif subject == 'SQS Message Processed':
                    print(f"Skipping SQS forward - message already processed by SQS Lambda")
            except Exception as e:
                print(f"Error sending to SQS: {str(e)}")
            
            return result
    
    return {
        'statusCode': 400,
        'body': json.dumps('No SNS message found in event')
    }

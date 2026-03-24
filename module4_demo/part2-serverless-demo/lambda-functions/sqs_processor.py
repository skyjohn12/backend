"""
Lambda Function: SQS Message Processor
Triggered by SQS queue - demonstrates queue-based serverless processing
"""

import json
import boto3 # type: ignore
from datetime import datetime

# Initialize AWS clients
sns = boto3.client('sns')

def lambda_handler(event, context):
    """
    Lambda function triggered by SQS queue
    Processes messages from the queue and sends notifications
    """
    
    print(f"Lambda function triggered at {datetime.now().isoformat()}")
    print(f"Number of messages: {len(event['Records'])}")
    
    processed_messages = []
    
    # Process each message from SQS
    for record in event['Records']:
        message_id = record['messageId']
        receipt_handle = record['receiptHandle']
        body = record['body']
        
        print(f"Processing message {message_id}")
        print(f"Message body: {body}")
        
        try:
            # Parse message body
            message_data = json.loads(body)
            
            # Process the message
            processing_result = {
                'message_id': message_id,
                'status': 'processed',
                'data': message_data,
                'processed_at': datetime.now().isoformat(),
                'service_type': 'PaaS - AWS Lambda + SQS'
            }
            
            processed_messages.append(processing_result)
            
            print(f"Message {message_id} processed successfully")
            
            # Optional: Send notification via SNS (DISABLED to prevent recursive loops in testing)
            # In production, you would send only essential summary data
            # try:
            #     import os
            #     topic_arn = os.environ.get('SNS_TOPIC_ARN')
            #     
            #     if topic_arn:
            #         notification_message = {
            #             'message_id': message_id,
            #             'status': 'processed',
            #             'processed_at': datetime.now().isoformat()
            #         }
            #         sns.publish(
            #             TopicArn=topic_arn,
            #             Subject='SQS Message Processed',
            #             Message=json.dumps(notification_message, indent=2)
            #         )
            #         print(f"Notification sent to SNS")
            # except Exception as e:
            #     print(f"Error sending SNS notification: {str(e)}")
                
        except json.JSONDecodeError as e:
            print(f"Error parsing message body: {str(e)}")
            processed_messages.append({
                'message_id': message_id,
                'status': 'error',
                'error': 'Invalid JSON',
                'processed_at': datetime.now().isoformat()
            })
        except Exception as e:
            print(f"Error processing message: {str(e)}")
            processed_messages.append({
                'message_id': message_id,
                'status': 'error',
                'error': str(e),
                'processed_at': datetime.now().isoformat()
            })
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'SQS messages processed',
            'processed_count': len(processed_messages),
            'results': processed_messages,
            'trigger': 'SQS Queue'
        })
    }

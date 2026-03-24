"""
Lambda Function: Task Notifier
Triggered by SNS when high-priority tasks are created
Formats and logs notification details

HOMEWORK: Complete the TODOs below to make this function work
"""

import json
import os
from datetime import datetime

def lambda_handler(event, context):
    """
    Lambda function triggered by SNS topic
    Processes high-priority task notifications
    
    Expected SNS message format:
    {
        "task_id": "task-12345",
        "title": "Task title",
        "priority": "high",
        "created_at": "ISO timestamp"
    }
    """
    
    print(f"Task notifier triggered at {datetime.now().isoformat()}")
    
    notifications_sent = []
    
    # Process each SNS record
    for record in event['Records']:
        if record['EventSource'] != 'aws:sns':
            print(f"Skipping non-SNS record: {record.get('EventSource')}")
            continue
        
        try:
            sns_message = record['Sns']['Message']
            message_id = record['Sns']['MessageId']
            
            print(f"Processing SNS message: {message_id}")
            
            # TODO 1: Parse the SNS message to extract task information
            # Hint: The message might be a JSON string or plain text
            # Handle both cases gracefully
            
            # YOUR CODE HERE
            task_info = None  # Replace this line
            
            # Try to parse as JSON, if fails treat as plain text
            try:
                task_info = json.loads(sns_message)
            except (json.JSONDecodeError, TypeError):
                # If not JSON, create a simple structure
                task_info = {
                    'message': sns_message,
                    'type': 'text'
                }
            
            # TODO 2: Extract task details from the parsed data
            # Get: task_id, title, priority, created_at (with defaults if missing)
            
            # YOUR CODE HERE
            task_id = task_info.get('task_id', 'unknown')
            title = task_info.get('title', 'No title')
            priority = task_info.get('priority', 'unknown')
            created_at = task_info.get('created_at', datetime.now().isoformat())
            
            # TODO 3: Format a nice notification message
            # Create a human-readable notification that includes:
            # - Clear alert that this is a high-priority task
            # - Task title and ID
            # - When it was created
            # Store in a variable called 'formatted_notification'
            
            # YOUR CODE HERE
            formatted_notification = f"""
            🚨 HIGH PRIORITY TASK ALERT 🚨
            
            Task ID: {task_id}
            Title: {title}
            Priority: {priority}
            Created: {created_at}
            
            This task requires immediate attention!
            """
            
            # TODO 4: Log the notification details
            # Use print() to send logs to CloudWatch
            # Include all relevant information
            
            # YOUR CODE HERE
            print("=" * 60)
            print(formatted_notification)
            print("=" * 60)
            
            # TODO 5: Create a notification record for the response
            notification_record = {
                'message_id': message_id,
                'task_id': task_id,
                'notification_sent_at': datetime.now().isoformat(),
                'status': 'success'
            }
            
            notifications_sent.append(notification_record)
            
            print(f"✓ Notification processed for task: {task_id}")
            
        except Exception as e:
            error_msg = f"Error processing notification: {str(e)}"
            print(f"✗ Error: {error_msg}")
            
            # TODO 6: Add error handling
            # Create an error record and append to notifications_sent
            
            # YOUR CODE HERE
            error_record = {
                'message_id': record['Sns'].get('MessageId', 'unknown'),
                'status': 'error',
                'error': error_msg,
                'timestamp': datetime.now().isoformat()
            }
            notifications_sent.append(error_record)
    
    # TODO 7: Return a proper response
    # Include statusCode, message, and count of notifications processed
    
    # YOUR CODE HERE
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Notifications processed',
            'count': len(notifications_sent),
            'results': notifications_sent
        })
    }


# TESTING NOTES:
# 1. This function doesn't need environment variables but you can add them if needed
#
# 2. Test with sample SNS event:
# {
#   "Records": [
#     {
#       "EventSource": "aws:sns",
#       "Sns": {
#         "MessageId": "test-msg-123",
#         "Message": "{\"task_id\": \"task-001\", \"title\": \"Critical Bug Fix\", \"priority\": \"high\", \"created_at\": \"2024-01-01T00:00:00Z\"}"
#       }
#     }
#   ]
# }
#
# 3. Check CloudWatch Logs to verify your formatted notification appears correctly
#
# 4. Make sure to configure SNS trigger when deploying:
#    aws lambda add-permission --function-name task-notifier \
#      --statement-id sns-invoke --action lambda:InvokeFunction \
#      --principal sns.amazonaws.com \
#      --source-arn YOUR-SNS-TOPIC-ARN

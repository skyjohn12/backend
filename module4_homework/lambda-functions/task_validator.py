"""
Lambda Function: Task Validator
Processes tasks from SQS queue and validates them

HOMEWORK: Complete the TODOs below to make this function work
"""

import json
import os
from datetime import datetime

def lambda_handler(event, context):
    """
    Lambda function triggered by SQS queue
    Validates task data and logs results
    
    Expected SQS message format:
    {
        "task_id": "task-12345",
        "title": "Task title",
        "description": "Task description",
        "priority": "high|medium|low",
        "created_at": "ISO timestamp"
    }
    """
    
    print(f"Task validator triggered at {datetime.now().isoformat()}")
    print(f"Processing {len(event['Records'])} message(s)")
    
    processed_tasks = []
    
    # Process each message from SQS
    for record in event['Records']:
        message_id = record['messageId']
        body = record['body']
        
        print(f"Processing message: {message_id}")
        
        try:
            # TODO 1: Parse the SQS message body to extract task data
            # Hint: The body is a JSON string, use json.loads()
            # Store the parsed data in a variable called 'task_data'
            
            # YOUR CODE HERE
            task_data = None  # Replace this line
            
            if task_data is None:
                raise ValueError("Failed to parse task data")
            
            # TODO 2: Validate that the task has all required fields
            # Required fields: title, description, priority
            # If any field is missing, raise a ValueError
            
            # YOUR CODE HERE
            required_fields = ['title', 'description', 'priority']
            # Add validation logic here
            
            # TODO 3: Validate that priority is one of: high, medium, low
            # If invalid, set a default value or raise an error
            
            # YOUR CODE HERE
            valid_priorities = ['high', 'medium', 'low']
            # Add priority validation here
            
            # TODO 4: Create a validation result object
            validation_result = {
                'message_id': message_id,
                'task_id': task_data.get('task_id', 'unknown'),
                'status': 'valid',  # or 'invalid' if validation fails
                'validated_at': datetime.now().isoformat(),
                'validator': 'task_validator_lambda'
            }
            
            processed_tasks.append(validation_result)
            
            # TODO 5: Log the validation result to CloudWatch
            # Use print() statements - Lambda automatically sends them to CloudWatch
            
            # YOUR CODE HERE
            print(f"✓ Task validated successfully: {task_data.get('title', 'N/A')}")
            
        except json.JSONDecodeError as e:
            error_msg = f"Invalid JSON in message body: {str(e)}"
            print(f"✗ Error: {error_msg}")
            processed_tasks.append({
                'message_id': message_id,
                'status': 'error',
                'error': error_msg,
                'validated_at': datetime.now().isoformat()
            })
            
        except ValueError as e:
            error_msg = f"Validation error: {str(e)}"
            print(f"✗ Error: {error_msg}")
            processed_tasks.append({
                'message_id': message_id,
                'status': 'error',
                'error': error_msg,
                'validated_at': datetime.now().isoformat()
            })
            
        except Exception as e:
            error_msg = f"Unexpected error: {str(e)}"
            print(f"✗ Error: {error_msg}")
            processed_tasks.append({
                'message_id': message_id,
                'status': 'error',
                'error': error_msg,
                'validated_at': datetime.now().isoformat()
            })
    
    # TODO 6: Return a proper response
    # The response should include statusCode and body
    # Return 200 for success, include count of processed tasks
    
    # YOUR CODE HERE
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Task validation complete',
            'processed_count': len(processed_tasks),
            'results': processed_tasks
        })
    }


# TESTING NOTES:
# 1. No environment variables are required for this function
#
# 2. Test with sample SQS message:
# {
#   "Records": [
#     {
#       "messageId": "test-123",
#       "body": "{\"task_id\": \"task-001\", \"title\": \"Test Task\", \"description\": \"Test Description\", \"priority\": \"high\", \"created_at\": \"2024-01-01T00:00:00Z\"}"
#     }
#   ]
# }
#
# 3. Check CloudWatch Logs after execution to verify your print statements appear

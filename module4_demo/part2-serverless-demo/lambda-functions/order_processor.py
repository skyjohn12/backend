"""
Lambda Function: Order Processing Demo
Demonstrates a real-world serverless application flow
Receives orders, validates them, and sends to processing queue
"""

import json
import boto3 # type: ignore
import os
from datetime import datetime
from decimal import Decimal

# Initialize AWS clients
sqs = boto3.client('sqs')
sns = boto3.client('sns')
dynamodb = boto3.resource('dynamodb')

def lambda_handler(event, context):
    """
    Main handler for order processing
    Can be triggered by API Gateway or directly
    """
    
    print(f"Order processing started at {datetime.now().isoformat()}")
    
    try:
        # Parse input (handle different trigger types)
        if 'body' in event:
            # API Gateway trigger
            order_data = json.loads(event['body'])
        else:
            # Direct invocation
            order_data = event
        
        print(f"Processing order: {json.dumps(order_data)}")
        
        # Validate order
        validation_result = validate_order(order_data)
        if not validation_result['valid']:
            return {
                'statusCode': 400,
                'body': json.dumps({
                    'message': 'Order validation failed',
                    'errors': validation_result['errors']
                })
            }
        
        # Generate order ID
        order_id = f"ORD-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        
        # Prepare order for processing
        order = {
            'order_id': order_id,
            'customer_name': order_data.get('customer_name'),
            'items': order_data.get('items'),
            'total_amount': order_data.get('total_amount'),
            'status': 'pending',
            'created_at': datetime.now().isoformat()
        }
        
        # Send to SQS for processing
        queue_url = os.environ.get('SQS_QUEUE_URL')
        if queue_url:
            sqs.send_message(
                QueueUrl=queue_url,
                MessageBody=json.dumps(order),
                MessageAttributes={
                    'OrderType': {
                        'StringValue': 'standard',
                        'DataType': 'String'
                    }
                }
            )
            print(f"Order {order_id} sent to processing queue")
        
        # Send confirmation via SNS
        topic_arn = os.environ.get('SNS_TOPIC_ARN')
        if topic_arn:
            sns.publish(
                TopicArn=topic_arn,
                Subject=f'New Order Received: {order_id}',
                Message=json.dumps({
                    'order_id': order_id,
                    'customer': order_data.get('customer_name'),
                    'amount': order_data.get('total_amount'),
                    'status': 'Order received and queued for processing'
                }, indent=2)
            )
            print(f"Confirmation sent via SNS")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Order received successfully',
                'order_id': order_id,
                'status': 'pending',
                'estimated_processing_time': '2-3 minutes',
                'architecture': 'Serverless (Lambda + SNS + SQS)'
            })
        }
        
    except Exception as e:
        print(f"Error processing order: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error processing order',
                'error': str(e)
            })
        }

def validate_order(order_data):
    """Validate order data"""
    errors = []
    
    if not order_data.get('customer_name'):
        errors.append('Customer name is required')
    
    if not order_data.get('items') or len(order_data['items']) == 0:
        errors.append('At least one item is required')
    
    if not order_data.get('total_amount') or order_data['total_amount'] <= 0:
        errors.append('Total amount must be greater than 0')
    
    return {
        'valid': len(errors) == 0,
        'errors': errors
    }

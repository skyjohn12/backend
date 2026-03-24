#!/bin/bash

#===============================================================================
# Lambda Deployment Helper Script - INCOMPLETE
# Students must complete the TODOs to deploy their Lambda functions
#===============================================================================

set -e

echo "======================================"
echo "Lambda Function Deployment Helper"
echo "======================================"
echo ""
echo "⚠️  HOMEWORK: Complete the TODOs in this script to deploy your Lambda functions"
echo ""

# Configuration
REGION="us-east-1"
LAMBDA_ROLE_NAME="task-lambda-execution-role"

# Get AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account: $ACCOUNT_ID"
echo ""

# TODO 1: Check if the IAM role exists
# Hint: aws iam get-role --role-name $LAMBDA_ROLE_NAME
echo "Checking IAM role..."
# YOUR CODE HERE

# TODO 2: Get the ARN of your SNS topic
# Hint: aws sns list-topics and filter for 'task-notifications'
echo "Getting SNS Topic ARN..."
SNS_TOPIC_ARN=""  # YOUR CODE HERE
echo "SNS Topic: $SNS_TOPIC_ARN"

# TODO 3: Get the URL of your SQS queue
# Hint: aws sqs get-queue-url --queue-name task-processing-queue
echo "Getting SQS Queue URL..."
SQS_QUEUE_URL=""  # YOUR CODE HERE
echo "SQS Queue: $SQS_QUEUE_URL"

echo ""
echo "======================================"
echo "Deploying task_validator Lambda"
echo "======================================"

# TODO 5: Package the task_validator function
# Hint: cd lambda-functions && zip task_validator.zip task_validator.py
echo "Packaging task_validator..."
# YOUR CODE HERE

# TODO 6: Create or update the task_validator Lambda function
# Use: aws lambda create-function or update-function-code
# Don't forget to set environment variables!
echo "Creating/updating task_validator Lambda..."
# YOUR CODE HERE

# TODO 7: Configure SQS trigger for task_validator
# Hint: aws lambda create-event-source-mapping
# IMPORTANT: Always use --enabled flag to ensure mapping is active!
# If mapping already exists, use update-event-source-mapping to enable it
echo "Setting up SQS trigger..."
# YOUR CODE HERE
# Example structure:
# aws lambda create-event-source-mapping \
#   --function-name task-validator \
#   --event-source-arn $SQS_QUEUE_ARN \
#   --batch-size 10 \
#   --enabled  # <-- Don't forget this!

echo ""
echo "======================================"
echo "Deploying task_notifier Lambda"
echo "======================================"

# TODO 8: Package the task_notifier function
echo "Packaging task_notifier..."
# YOUR CODE HERE

# TODO 9: Create or update the task_notifier Lambda function
echo "Creating/updating task_notifier Lambda..."
# YOUR CODE HERE

# TODO 10: Configure SNS trigger for task_notifier
# Hint: aws sns subscribe and aws lambda add-permission
# IMPORTANT: Check if subscription already exists before creating!
# Multiple subscriptions = Lambda triggered multiple times per message
echo "Setting up SNS trigger..."
# YOUR CODE HERE
# Step 1: Check for existing subscription (recommended):
# aws sns list-subscriptions-by-topic --topic-arn $SNS_TOPIC_ARN \
#   --query "Subscriptions[?Protocol=='lambda' && Endpoint=='YOUR-LAMBDA-ARN']"
#
# Step 2: Only create if none exist:
# aws sns subscribe \
#   --topic-arn $SNS_TOPIC_ARN \
#   --protocol lambda \
#   --notification-endpoint YOUR-LAMBDA-ARN
#
# Step 3: Grant SNS permission to invoke Lambda:
# aws lambda add-permission \
#   --function-name task-notifier \
#   --statement-id sns-invoke \
#   --action lambda:InvokeFunction \
#   --principal sns.amazonaws.com \
#   --source-arn $SNS_TOPIC_ARN

echo ""
echo "======================================"
echo "✓ Deployment Complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "1. Test your Lambda functions in AWS Console"
echo "2. Check CloudWatch Logs for execution logs"
echo "3. Test the event-driven flow by sending messages to SQS and SNS"
echo ""
echo "Verify deployment:"
echo "  aws lambda list-functions --query 'Functions[?starts_with(FunctionName, \`task\`)].FunctionName'"

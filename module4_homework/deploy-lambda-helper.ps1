#===============================================================================
# Lambda Deployment Helper Script - INCOMPLETE
# Students must complete the TODOs to deploy their Lambda functions
#===============================================================================

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Lambda Function Deployment Helper" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  HOMEWORK: Complete the TODOs in this script to deploy your Lambda functions" -ForegroundColor Yellow
Write-Host ""

# Configuration
$REGION = "us-east-1"
$LAMBDA_ROLE_NAME = "task-lambda-execution-role"

# Get AWS Account ID
$ACCOUNT_ID = aws sts get-caller-identity --query Account --output text
Write-Host "AWS Account: $ACCOUNT_ID" -ForegroundColor Green
Write-Host ""

# TODO 1: Check if the IAM role exists
# Hint: aws iam get-role --role-name $LAMBDA_ROLE_NAME
Write-Host "Checking IAM role..." -ForegroundColor Cyan
# YOUR CODE HERE

# TODO 2: Get the ARN of your SNS topic
# Hint: aws sns list-topics and filter for 'task-notifications'
Write-Host "Getting SNS Topic ARN..." -ForegroundColor Cyan
$SNS_TOPIC_ARN = ""  # YOUR CODE HERE
Write-Host "SNS Topic: $SNS_TOPIC_ARN" -ForegroundColor Green

# TODO 3: Get the URL of your SQS queue
# Hint: aws sqs get-queue-url --queue-name task-processing-queue
Write-Host "Getting SQS Queue URL..." -ForegroundColor Cyan
$SQS_QUEUE_URL = ""  # YOUR CODE HERE
Write-Host "SQS Queue: $SQS_QUEUE_URL" -ForegroundColor Green

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Deploying task_validator Lambda" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# TODO 5: Package the task_validator function
# Hint: Create a zip file containing task_validator.py
Write-Host "Packaging task_validator..." -ForegroundColor Cyan
# YOUR CODE HERE
# Example: Compress-Archive -Path .\lambda-functions\task_validator.py -DestinationPath .\lambda-functions\task_validator.zip -Force

# TODO 6: Create or update the task_validator Lambda function
# Use: aws lambda create-function or update-function-code
# Don't forget to set environment variables!
Write-Host "Creating/updating task_validator Lambda..." -ForegroundColor Cyan
# YOUR CODE HERE

# TODO 7: Configure SQS trigger for task_validator
# Hint: aws lambda create-event-source-mapping
Write-Host "Setting up SQS trigger..." -ForegroundColor Cyan
# YOUR CODE HERE

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Deploying task_notifier Lambda" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan

# TODO 8: Package the task_notifier function
Write-Host "Packaging task_notifier..." -ForegroundColor Cyan
# YOUR CODE HERE

# TODO 9: Create or update the task_notifier Lambda function
Write-Host "Creating/updating task_notifier Lambda..." -ForegroundColor Cyan
# YOUR CODE HERE

# TODO 10: Configure SNS trigger for task_notifier
# Hint: aws sns subscribe and aws lambda add-permission
Write-Host "Setting up SNS trigger..." -ForegroundColor Cyan
# YOUR CODE HERE

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "✓ Deployment Complete!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Test your Lambda functions in AWS Console"
Write-Host "2. Check CloudWatch Logs for execution logs"
Write-Host "3. Test the event-driven flow by sending messages to SQS and SNS"
Write-Host ""
Write-Host "Verify deployment:"
Write-Host "  aws lambda list-functions --query 'Functions[?starts_with(FunctionName, ``task``)].FunctionName'"

# Module 4 Homework - Quick Reference (Serverless Only)

## File Structure
```
module4_homework/
├── README.md                       # Main homework instructions
├── TESTING_GUIDE.md                # Testing examples
├── COMMON_ISSUES.md                # ⭐ Troubleshooting guide (READ THIS!)
├── QUICK_START.md                  # This file
├── verify-homework.sh              # Verification script (bash)
├── verify-homework.ps1             # Verification script (PowerShell)
├── deploy-lambda-helper.sh         # Lambda deployment helper (INCOMPLETE)
├── deploy-lambda-helper.ps1        # Lambda deployment helper (PowerShell)
└── lambda-functions/
    ├── task_validator.py           # Lambda function (INCOMPLETE - TODO)
    └── task_notifier.py            # Lambda function (INCOMPLETE - TODO)
```

## ⚠️ IMPORTANT: Read This First!
Before starting, review **`COMMON_ISSUES.md`** - it contains solutions to the most common problems students face (disabled event mappings, duplicate subscriptions, etc.).

## Quick Start Guide

### 1. Authenticate
```bash
aws-azure-login -m gui --no-sandbox
aws sts get-caller-identity
```

### 2. Create AWS Resources
```bash
# SNS Topic
aws sns create-topic --name task-notifications --region us-east-1

# Subscribe email (replace with your email and account ID)
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:YOUR-ACCOUNT-ID:task-notifications \
  --protocol email \
  --notification-endpoint your@email.com

# SQS Queue
aws sqs create-queue --queue-name task-processing-queue --region us-east-1

# IAM Role (see README for detailed steps)
# Create trust policy, create role, attach policies
```

### 3. Complete Lambda Code
- `lambda-functions/task_validator.py` - Complete TODOs 1-6
- `lambda-functions/task_notifier.py` - Complete TODOs 1-7

### 4. Deploy Lambda Functions
```bash
cd lambda-functions

# Package and deploy task_validator
zip task_validator.zip task_validator.py
aws lambda create-function \
  --function-name task-validator \
  --runtime python3.9 \
  --role arn:aws:iam::YOUR-ACCOUNT-ID:role/task-lambda-execution-role \
  --handler task_validator.lambda_handler \
  --zip-file fileb://task_validator.zip \
  --timeout 30 \
  --region us-east-1

# Configure SQS trigger
aws lambda create-event-source-mapping \
  --function-name task-validator \
  --event-source-arn YOUR-SQS-ARN \
  --batch-size 1

# Package and deploy task_notifier
zip task_notifier.zip task_notifier.py
aws lambda create-function \
  --function-name task-notifier \
  --runtime python3.9 \
  --role arn:aws:iam::YOUR-ACCOUNT-ID:role/task-lambda-execution-role \
  --handler task_notifier.lambda_handler \
  --zip-file fileb://task_notifier.zip \
  --timeout 30 \
  --region us-east-1

# Configure SNS trigger
aws sns subscribe \
  --topic-arn YOUR-SNS-TOPIC-ARN \
  --protocol lambda \
  --notification-endpoint arn:aws:lambda:us-east-1:YOUR-ACCOUNT-ID:function:task-notifier

aws lambda add-permission \
  --function-name task-notifier \
  --statement-id sns-invoke \
  --action lambda:InvokeFunction \
  --principal sns.amazonaws.com \
  --source-arn YOUR-SNS-TOPIC-ARN
```

### 5. Test
```bash
# Test SQS → Lambda
aws sqs send-message \
  --queue-url YOUR-QUEUE-URL \
  --message-body '{"task_id":"test-001","title":"Test Task","description":"Testing","priority":"high","created_at":"2024-01-15T10:00:00Z"}'

# Check logs
aws logs tail /aws/lambda/task-validator --follow

# Test SNS → Lambda  
aws sns publish \
  --topic-arn YOUR-SNS-TOPIC-ARN \
  --subject "Test" \
  --message '{"task_id":"test-002","title":"Test","priority":"high"}'

# Check logs
aws logs tail /aws/lambda/task-notifier --follow
```

### 6. Verify
```bash
chmod +x verify-homework.sh
./verify-homework.sh
```

### 7. Clean Up
```bash
# When finished, delete all resources
# See README.md cleanup section for commands
```

## Useful Commands

### Check Resources
```bash
# List Lambda functions
aws lambda list-functions --query 'Functions[?starts_with(FunctionName, `task`)].FunctionName'

# View logs
aws logs tail /aws/lambda/task-validator --follow
aws logs tail /aws/lambda/task-notifier --follow

# Check SQS queue
aws sqs get-queue-attributes --queue-url YOUR-QUEUE-URL --attribute-names All

# Check SNS subscriptions
aws sns list-subscriptions-by-topic --topic-arn YOUR-SNS-TOPIC-ARN
```

### Troubleshooting
```bash
# Test Lambda locally
aws lambda invoke \
  --function-name task-validator \
  --payload file://test-event.json \
  --cli-binary-format raw-in-base64-out \
  output.json

# Check IAM role
aws iam get-role --role-name task-lambda-execution-role

# View SQS messages
aws sqs receive-message --queue-url YOUR-QUEUE-URL --max-number-of-messages 10
```

## Need Help?
- Review the demo code in `module4_demo/part2-serverless-demo/`
- Check TESTING_GUIDE.md for sample events
- Use `verify-homework.sh` to identify issues
- See README.md for detailed instructions


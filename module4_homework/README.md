# Module 4 Homework: AWS Serverless Architecture - Hands-On Assignment

## 🎯 Overview

This homework assignment builds on the AWS Cloud Foundations demo you saw in class. You will implement a **Serverless Task Notification System** using AWS Lambda, SNS, and SQS.

**Estimated Time**: 1.5-2 hours

**Learning Objectives**:
- Implement AWS Lambda functions with event-driven triggers
- Configure SNS topics and email subscriptions
- Set up SQS queues and integrate with Lambda
- Configure IAM roles and permissions manually
- Debug using CloudWatch logs
- Understand serverless event-driven architecture

---

## 🚨 Security Compliance Requirements

Before you begin, ensure you comply with AWS security policies:

- ✅ **IAM roles**: Use least-privilege permissions
- ✅ **Resource lifecycle**: Delete all resources within 2 weeks
- ✅ **Authentication**: Use `aws-azure-login` for Slalom accounts

---

## 📋 What You Need to Build

### Serverless Task Notification System
Build two AWS Lambda functions that work together:

1. **Task Validator Lambda**: 
   - Triggered by SQS queue
   - Receives task messages and validates them
   - Checks for required fields (title, description, priority)
   - Logs validation results to CloudWatch

2. **Task Notifier Lambda**:
   - Triggered by SNS topic
   - Receives high-priority task notifications
   - Formats notification messages
   - Logs notification details to CloudWatch

**Architecture Flow**:
```
User sends message to SQS → Task Validator Lambda processes it
User publishes to SNS → Task Notifier Lambda handles notification
```

---

## 🛠️ What You Must Do Manually (NOT Automated)

### ❌ The following CANNOT be automated - you must do them yourself:

1. **Set up SNS topic** and subscribe your email
2. **Create SQS queue** and configure message retention
3. **Configure IAM policies** for Lambda execution role
4. **Complete the Lambda function code** (starter code provided with TODOs)
5. **Deploy Lambda functions** manually with correct environment variables
6. **Configure Lambda triggers** for SQS and SNS
7. **Test the integration** end-to-end and fix any issues
8. **Debug using CloudWatch logs**

---

## 📁 Starter Code Provided

You have been given:
- **Incomplete Lambda functions** (`lambda-functions/`) - with TODO comments
- **Helper script** (`deploy-lambda-helper.sh`) - needs completion
- **Deployment guide** (this README)

---

## � Platform Compatibility

This homework works on **macOS, Linux, and Windows**.

### For Windows Users:
You have two options:

**Option 1: Use WSL2 (Recommended)**
- Install [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) with Ubuntu
- Follow the Linux/macOS instructions
- All commands work identically

**Option 2: Use PowerShell**
- Use PowerShell versions of scripts provided (`deploy-lambda-helper.ps1`, `verify-homework.ps1`)
- Some command syntax differs (documented below)
- AWS CLI commands are identical across platforms

---

## 🚀 Step-by-Step Instructions

### Prerequisites

#### macOS/Linux:
```bash
# AWS CLI
brew install awscli  # macOS
# or
sudo apt install awscli  # Linux

# Python 3.9+
python3 --version
```

#### Windows (PowerShell):
```powershell
# Install AWS CLI - Download from: https://aws.amazon.com/cli/
# Or use Chocolatey:
choco install awscli

# Python 3.9+ - Download from: https://www.python.org/downloads/
python --version
```

### Authenticate with AWS

```bash
# For Slalom accounts (Azure AD) - Same on all platforms
aws-azure-login -m gui --no-sandbox

# Verify authentication
aws sts get-caller-identity
```

---

### Step 1: Set Up AWS Resources

#### Task 1.1: Create SNS Topic (Manual)

**macOS/Linux:**
```bash
# Create SNS topic
aws sns create-topic --name task-notifications --region us-east-1

# Subscribe YOUR email (replace with your email and account ID)
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:YOUR-ACCOUNT-ID:task-notifications \
  --protocol email \
  --notification-endpoint your-email@example.com
```

**Windows PowerShell:**
```powershell
# Create SNS topic (same command)
aws sns create-topic --name task-notifications --region us-east-1

# Subscribe YOUR email (use backticks for line continuation)
aws sns subscribe `
  --topic-arn arn:aws:sns:us-east-1:YOUR-ACCOUNT-ID:task-notifications `
  --protocol email `
  --notification-endpoint your-email@example.com
```

**⚠️ You must confirm the subscription via email!**

#### Task 1.2: Create SQS Queue (Manual)

```bash
# Create SQS queue with 1-hour message retention (same on all platforms)
aws sqs create-queue \
  --queue-name task-processing-queue \
  --attributes MessageRetentionPeriod=3600 \
  --region us-east-1

# Get the queue URL (you'll need this later)
aws sqs get-queue-url --queue-name task-processing-queue --region us-east-1
```

**Windows users**: Replace `\` with `` ` `` (backtick) for line continuations.

**Save your queue URL for later!**

#### Task 1.3: Create IAM Role for Lambda (Manual)

You need to:
1. Create a trust policy JSON file
2. Create the IAM role
3. Attach necessary policies:
   - `AWSLambdaBasicExecutionRole`
   - `AmazonSNSFullAccess`
   - `AmazonSQSFullAccess`

**Hint**: Look at the demo's `deploy-lambda.sh` for reference, but you must run commands manually.

**macOS/Linux:**
```bash
# Create trust policy file
cat > /tmp/lambda-trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "lambda.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

# Create the role
aws iam create-role \
  --role-name task-lambda-execution-role \
  --assume-role-policy-document file:///tmp/lambda-trust-policy.json

# Attach policies
aws iam attach-role-policy \
  --role-name task-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy \
  --role-name task-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess

aws iam attach-role-policy \
  --role-name task-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess

# Wait for IAM propagation
sleep 10
```

**Windows PowerShell:**
```powershell
# Create trust policy file
$trustPolicy = @'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "lambda.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
'@

$trustPolicy | Out-File -FilePath "$env:TEMP\lambda-trust-policy.json" -Encoding utf8

# Create the role
aws iam create-role `
  --role-name task-lambda-execution-role `
  --assume-role-policy-document "file://$env:TEMP/lambda-trust-policy.json"

# Attach policies
aws iam attach-role-policy `
  --role-name task-lambda-execution-role `
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam attach-role-policy `
  --role-name task-lambda-execution-role `
  --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess

aws iam attach-role-policy `
  --role-name task-lambda-execution-role `
  --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess

# Wait for IAM propagation
Start-Sleep -Seconds 10
```

---

### Step 2: Complete the Lambda Functions

#### Lambda Function 1: Task Validator (`lambda-functions/task_validator.py`)

Open the file and complete the TODOs:
- **TODO 1**: Parse SQS message body and extract task data
- **TODO 2**: Validate task has required fields (title, description, priority)
- **TODO 3**: Validate priority values (high, medium, low)
- **TODO 4**: Create validation result object
- **TODO 5**: Log to CloudWatch
- **TODO 6**: Return proper response structure

#### Lambda Function 2: Task Notifier (`lambda-functions/task_notifier.py`)

Open the file and complete the TODOs:
- **TODO 1**: Parse SNS message
- **TODO 2**: Extract task details
- **TODO 3**: Format notification message
- **TODO 4**: Log notification details
- **TODO 5**: Create notification record
- **TODO 6**: Add error handling
- **TODO 7**: Return proper response

---

### Step 3: Deploy Lambda Functions

#### Deploy task_validator:

**macOS/Linux:**
```bash
cd lambda-functions

# Package the function
zip task_validator.zip task_validator.py

# Create Lambda function
aws lambda create-function \
  --function-name task-validator \
  --runtime python3.9 \
  --role arn:aws:iam::YOUR-ACCOUNT-ID:role/task-lambda-execution-role \
  --handler task_validator.lambda_handler \
  --zip-file fileb://task_validator.zip \
  --timeout 30 \
  --region us-east-1

# Configure SQS trigger
SQS_ARN=$(aws sqs get-queue-attributes \
  --queue-url YOUR-QUEUE-URL \
  --attribute-names QueueArn \
  --query 'Attributes.QueueArn' \
  --output text)

aws lambda create-event-source-mapping \
  --function-name task-validator \
  --event-source-arn $SQS_ARN \
  --batch-size 1
```

**Windows PowerShell:**
```powershell
cd lambda-functions

# Package the function
Compress-Archive -Path task_validator.py -DestinationPath task_validator.zip -Force

# Create Lambda function
aws lambda create-function `
  --function-name task-validator `
  --runtime python3.9 `
  --role arn:aws:iam::YOUR-ACCOUNT-ID:role/task-lambda-execution-role `
  --handler task_validator.lambda_handler `
  --zip-file fileb://task_validator.zip `
  --timeout 30 `
  --region us-east-1

# Configure SQS trigger
$SQS_ARN = aws sqs get-queue-attributes `
  --queue-url YOUR-QUEUE-URL `
  --attribute-names QueueArn `
  --query 'Attributes.QueueArn' `
  --output text

aws lambda create-event-source-mapping `
  --function-name task-validator `
  --event-source-arn $SQS_ARN `
  --batch-size 1
```

#### Deploy task_notifier:

**macOS/Linux:**
```bash
# Package the function
zip task_notifier.zip task_notifier.py

# Create Lambda function
aws lambda create-function \
  --function-name task-notifier \
  --runtime python3.9 \
  --role arn:aws:iam::YOUR-ACCOUNT-ID:role/task-lambda-execution-role \
  --handler task_notifier.lambda_handler \
  --zip-file fileb://task_notifier.zip \
  --timeout 30 \
  --region us-east-1

# Subscribe to SNS topic
aws sns subscribe \
  --topic-arn YOUR-SNS-TOPIC-ARN \
  --protocol lambda \
  --notification-endpoint arn:aws:lambda:us-east-1:YOUR-ACCOUNT-ID:function:task-notifier

# Grant SNS permission to invoke Lambda
aws lambda add-permission \
  --function-name task-notifier \
  --statement-id sns-invoke \
  --action lambda:InvokeFunction \
  --principal sns.amazonaws.com \
  --source-arn YOUR-SNS-TOPIC-ARN
```

**Windows PowerShell:**
```powershell
# Package the function
Compress-Archive -Path task_notifier.py -DestinationPath task_notifier.zip -Force

# Create Lambda function
aws lambda create-function `
  --function-name task-notifier `
  --runtime python3.9 `
  --role arn:aws:iam::YOUR-ACCOUNT-ID:role/task-lambda-execution-role `
  --handler task_notifier.lambda_handler `
  --zip-file fileb://task_notifier.zip `
  --timeout 30 `
  --region us-east-1

# Subscribe to SNS topic
aws sns subscribe `
  --topic-arn YOUR-SNS-TOPIC-ARN `
  --protocol lambda `
  --notification-endpoint arn:aws:lambda:us-east-1:YOUR-ACCOUNT-ID:function:task-notifier

# Grant SNS permission to invoke Lambda
aws lambda add-permission `
  --function-name task-notifier `
  --statement-id sns-invoke `
  --action lambda:InvokeFunction `
  --principal sns.amazonaws.com `
  --source-arn YOUR-SNS-TOPIC-ARN
```

---

### Step 4: Test Your Lambda Functions

#### Test task_validator with SQS:

**macOS/Linux:**
```bash
# Send a test message to SQS
aws sqs send-message \
  --queue-url YOUR-QUEUE-URL \
  --message-body '{"task_id":"test-001","title":"Test Task","description":"Testing the validator","priority":"high","created_at":"2024-01-15T10:00:00Z"}'

# Check CloudWatch logs
aws logs tail /aws/lambda/task-validator --follow
```

**Windows PowerShell:**
```powershell
# Send a test message to SQS
aws sqs send-message `
  --queue-url YOUR-QUEUE-URL `
  --message-body '{\"task_id\":\"test-001\",\"title\":\"Test Task\",\"description\":\"Testing the validator\",\"priority\":\"high\",\"created_at\":\"2024-01-15T10:00:00Z\"}'

# Check CloudWatch logs
aws logs tail /aws/lambda/task-validator --follow
```

#### Test task_notifier with SNS:

**macOS/Linux:**
```bash
# Publish a test notification to SNS
aws sns publish \
  --topic-arn YOUR-SNS-TOPIC-ARN \
  --subject "Test High Priority Task" \
  --message '{"task_id":"test-002","title":"Critical Bug","priority":"high","created_at":"2024-01-15T10:05:00Z"}'

# Check CloudWatch logs
aws logs tail /aws/lambda/task-notifier --follow

# Check your email for the notification
```

**Windows PowerShell:**
```powershell
# Publish a test notification to SNS
aws sns publish `
  --topic-arn YOUR-SNS-TOPIC-ARN `
  --subject "Test High Priority Task" `
  --message '{\"task_id\":\"test-002\",\"title\":\"Critical Bug\",\"priority\":\"high\",\"created_at\":\"2024-01-15T10:05:00Z\"}'

# Check CloudWatch logs
aws logs tail /aws/lambda/task-notifier --follow

# Check your email for the notification
```

#### Verify Everything Works:

1. **SQS message processed**: Check CloudWatch logs show validation
2. **SNS notification sent**: Check your email for the notification
3. **No errors**: Both Lambda functions execute successfully
4. **Logs are clear**: CloudWatch shows detailed logging

---

## 🧹 Cleanup Resources

**IMPORTANT**: Clean up all AWS resources when you're done to avoid charges.

**macOS/Linux:**
```bash
# Delete Lambda event source mapping
aws lambda list-event-source-mappings --function-name task-validator \
  --query 'EventSourceMappings[0].UUID' --output text | \
  xargs -I {} aws lambda delete-event-source-mapping --uuid {}

# Delete Lambda functions
aws lambda delete-function --function-name task-validator
aws lambda delete-function --function-name task-notifier

# Delete SQS queue
aws sqs delete-queue --queue-url YOUR-QUEUE-URL

# Delete SNS topic
aws sns delete-topic --topic-arn YOUR-TOPIC-ARN

# Detach policies from IAM role
aws iam detach-role-policy --role-name task-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam detach-role-policy --role-name task-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
aws iam detach-role-policy --role-name task-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess

# Delete IAM role
aws iam delete-role --role-name task-lambda-execution-role
```

**Windows PowerShell:**
```powershell
# Delete Lambda event source mapping
$mappingUUID = aws lambda list-event-source-mappings --function-name task-validator `
  --query 'EventSourceMappings[0].UUID' --output text

aws lambda delete-event-source-mapping --uuid $mappingUUID

# Delete Lambda functions
aws lambda delete-function --function-name task-validator
aws lambda delete-function --function-name task-notifier

# Delete SQS queue
aws sqs delete-queue --queue-url YOUR-QUEUE-URL

# Delete SNS topic
aws sns delete-topic --topic-arn YOUR-TOPIC-ARN

# Detach policies from IAM role
aws iam detach-role-policy --role-name task-lambda-execution-role `
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam detach-role-policy --role-name task-lambda-execution-role `
  --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
aws iam detach-role-policy --role-name task-lambda-execution-role `
  --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess

# Delete IAM role
aws iam delete-role --role-name task-lambda-execution-role
```

**Include a screenshot showing all resources deleted.**

---

## 🆘 Troubleshooting Tips

### ⚠️ COMMON ISSUES - Read This First!

#### Issue: SQS messages not triggering Lambda (event source mapping disabled)
**Symptoms**: SQS queue receives messages but Lambda function never executes, no CloudWatch logs
**Root Cause**: Event source mapping exists but is in "Disabled" state
**Solution**:
```bash
# Check if mapping exists and its state
aws lambda list-event-source-mappings --function-name task-validator

# If State is "Disabled", enable it:
aws lambda update-event-source-mapping --uuid YOUR-UUID --enabled

# Or delete and recreate:
aws lambda delete-event-source-mapping --uuid YOUR-UUID
aws lambda create-event-source-mapping \
  --function-name task-validator \
  --event-source-arn YOUR-SQS-ARN \
  --batch-size 10 \
  --enabled
```

#### Issue: Lambda triggered twice for each message (duplicate subscriptions)
**Symptoms**: Two log streams created for single SNS message, function executes twice
**Root Cause**: Multiple SNS subscriptions pointing to same Lambda function
**Solution**:
```bash
# List all subscriptions for your SNS topic
aws sns list-subscriptions-by-topic --topic-arn YOUR-TOPIC-ARN

# If you see duplicates (same Endpoint, different SubscriptionArn), remove extras:
aws sns unsubscribe --subscription-arn DUPLICATE-SUBSCRIPTION-ARN

# Keep only one subscription per Lambda function
```
**Prevention**: Before creating a subscription, check if one already exists:
```bash
# Check existing subscriptions
aws sns list-subscriptions-by-topic --topic-arn YOUR-TOPIC-ARN \
  --query "Subscriptions[?Protocol=='lambda' && Endpoint=='YOUR-LAMBDA-ARN']"

# Only create if none exist
```

#### Issue: Lambda function can't be invoked
**Solution**: Check IAM role permissions and ensure role is attached to function

#### Issue: SNS notifications not received
**Solution**: Confirm email subscription in your inbox (check spam folder too!)

#### Issue: SQS messages not processed
**Solution**: 
1. Verify event source mapping is **enabled** (see first issue above)
2. Check CloudWatch logs for errors
3. Verify IAM role has SQS permissions

### Issue: "Unable to import module"  
**Solution**: Check your zip file structure - Python file should be at root of zip

### Issue: CloudWatch logs not appearing
**Solution**: Ensure IAM role has AWSLambdaBasicExecutionRole attached

### Issue: "Access Denied" errors
**Solution**: Verify IAM role ARNs are correct and policies are attached

---

## 📚 Helpful Resources

- **⭐ [`COMMON_ISSUES.md`](COMMON_ISSUES.md)** - Quick fixes for most common problems
- [AWS CLI Command Reference](https://docs.aws.amazon.com/cli/)
- [Lambda Python Guide](https://docs.aws.amazon.com/lambda/latest/dg/lambda-python.html)
- [SQS Integration with Lambda](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html)
- [SNS Integration with Lambda](https://docs.aws.amazon.com/lambda/latest/dg/with-sns.html)
- Review the demo code in `module4_demo/part2-serverless-demo/` folder

---

## 💡 Learning Goals

By completing this homework, you will understand:
- How serverless event-driven architecture works
- The difference between push (SNS) and pull (SQS) messaging patterns
- How Lambda functions are triggered by different event sources
- The importance of IAM roles for granting permissions
- How to debug serverless applications using CloudWatch logs

---

Good luck! Remember: The goal is to understand how these services work together, not just to get it running. Take time to explore the AWS Console and understand what each service is doing.

🚀 **Pro Tip**: Test each Lambda function individually before integrating them together!

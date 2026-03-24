#!/bin/bash

# Lambda Deployment Script
# Deploys all Lambda functions with SNS and SQS integration

set -e

echo "======================================"
echo "AWS Lambda Serverless Demo Setup"
echo "======================================"
echo ""

# Configuration
REGION="us-east-1"
SNS_TOPIC_NAME="demo-notifications"
SQS_QUEUE_NAME="demo-processing-queue"
LAMBDA_ROLE_NAME="demo-lambda-execution-role"

echo "Step 1: Checking AWS CLI configuration..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo ""
    echo "❌ Error: AWS credentials are invalid or expired"
    echo ""
    echo "Please refresh your credentials:"
    echo "  1. If using aws-azure-login: Run 'aws-azure-login'"
    echo "  2. If using AWS Academy: Get new credentials from AWS Details"
    echo "  3. If using SSO: Run 'aws sso login'"
    echo ""
    echo "After refreshing credentials, run this script again."
    echo ""
    exit 1
fi
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✓ AWS credentials valid (Account: $ACCOUNT_ID)"
echo ""

echo "Step 2: Creating IAM role for Lambda..."
# Check if role exists
if aws iam get-role --role-name $LAMBDA_ROLE_NAME 2>/dev/null; then
    echo "✓ IAM role already exists"
    ROLE_ARN=$(aws iam get-role --role-name $LAMBDA_ROLE_NAME --query 'Role.Arn' --output text)
else
    # Create trust policy
    cat > /tmp/trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    # Create role
    ROLE_ARN=$(aws iam create-role \
        --role-name $LAMBDA_ROLE_NAME \
        --assume-role-policy-document file:///tmp/trust-policy.json \
        --query 'Role.Arn' \
        --output text)
    
    echo "✓ Created IAM role: $ROLE_ARN"
    
    # Attach policies
    aws iam attach-role-policy \
        --role-name $LAMBDA_ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
    
    aws iam attach-role-policy \
        --role-name $LAMBDA_ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
    
    aws iam attach-role-policy \
        --role-name $LAMBDA_ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess
    
    echo "✓ Attached necessary policies"
    echo "⏳ Waiting 10 seconds for IAM role to propagate..."
    sleep 10
fi
echo ""

echo "Step 3: Creating SNS topic..."
SNS_TOPIC_ARN=$(aws sns create-topic \
    --name $SNS_TOPIC_NAME \
    --region $REGION \
    --query 'TopicArn' \
    --output text 2>/dev/null || aws sns list-topics --query "Topics[?contains(TopicArn, '$SNS_TOPIC_NAME')].TopicArn" --output text)

echo "✓ SNS Topic: $SNS_TOPIC_ARN"

# Subscribe to SNS topic (optional - for demo purposes)
echo "  📧 Subscribe your email to receive notifications:"
echo "     aws sns subscribe --topic-arn $SNS_TOPIC_ARN --protocol email --notification-endpoint guila.meiralins@slalom.com"
echo ""

echo "Step 4: Creating SQS queue..."
SQS_QUEUE_URL=$(aws sqs create-queue \
    --queue-name $SQS_QUEUE_NAME \
    --region $REGION \
    --query 'QueueUrl' \
    --output text 2>/dev/null || aws sqs get-queue-url --queue-name $SQS_QUEUE_NAME --query 'QueueUrl' --output text)

echo "✓ SQS Queue: $SQS_QUEUE_URL"

# Get queue ARN
SQS_QUEUE_ARN=$(aws sqs get-queue-attributes \
    --queue-url $SQS_QUEUE_URL \
    --attribute-names QueueArn \
    --query 'Attributes.QueueArn' \
    --output text)
echo ""

echo "Step 5: Packaging Lambda functions..."

# Package SNS Handler
cd lambda-functions
zip -q sns_handler.zip sns_handler.py
echo "✓ Packaged sns_handler.py"

# Package SQS Processor
zip -q sqs_processor.zip sqs_processor.py
echo "✓ Packaged sqs_processor.py"

# Package Order Processor
zip -q order_processor.zip order_processor.py
echo "✓ Packaged order_processor.py"
echo ""

echo "Step 6: Deploying Lambda functions..."

# Deploy SNS Handler Lambda
SNS_LAMBDA_ARN=$(aws lambda create-function \
    --function-name demo-sns-handler \
    --runtime python3.9 \
    --role $ROLE_ARN \
    --handler sns_handler.lambda_handler \
    --zip-file fileb://sns_handler.zip \
    --environment "Variables={SQS_QUEUE_URL=$SQS_QUEUE_URL}" \
    --timeout 30 \
    --region $REGION \
    --query 'FunctionArn' \
    --output text 2>/dev/null || aws lambda update-function-code \
    --function-name demo-sns-handler \
    --zip-file fileb://sns_handler.zip \
    --query 'FunctionArn' \
    --output text)

echo "✓ Deployed SNS Handler Lambda: $SNS_LAMBDA_ARN"

# Deploy SQS Processor Lambda
SQS_LAMBDA_ARN=$(aws lambda create-function \
    --function-name demo-sqs-processor \
    --runtime python3.9 \
    --role $ROLE_ARN \
    --handler sqs_processor.lambda_handler \
    --zip-file fileb://sqs_processor.zip \
    --environment "Variables={SNS_TOPIC_ARN=$SNS_TOPIC_ARN}" \
    --timeout 30 \
    --region $REGION \
    --query 'FunctionArn' \
    --output text 2>/dev/null || aws lambda update-function-code \
    --function-name demo-sqs-processor \
    --zip-file fileb://sqs_processor.zip \
    --query 'FunctionArn' \
    --output text)

echo "✓ Deployed SQS Processor Lambda: $SQS_LAMBDA_ARN"

# Deploy Order Processor Lambda
ORDER_LAMBDA_ARN=$(aws lambda create-function \
    --function-name demo-order-processor \
    --runtime python3.9 \
    --role $ROLE_ARN \
    --handler order_processor.lambda_handler \
    --zip-file fileb://order_processor.zip \
    --environment "Variables={SQS_QUEUE_URL=$SQS_QUEUE_URL,SNS_TOPIC_ARN=$SNS_TOPIC_ARN}" \
    --timeout 30 \
    --region $REGION \
    --query 'FunctionArn' \
    --output text 2>/dev/null || aws lambda update-function-code \
    --function-name demo-order-processor \
    --zip-file fileb://order_processor.zip \
    --query 'FunctionArn' \
    --output text)

echo "✓ Deployed Order Processor Lambda: $ORDER_LAMBDA_ARN"

cd ..
echo ""

echo "Step 7: Configuring triggers..."

# Check for duplicate SNS subscriptions and clean them up
ALL_SUBSCRIPTIONS=$(aws sns list-subscriptions-by-topic \
    --topic-arn $SNS_TOPIC_ARN \
    --query "Subscriptions[?Protocol=='lambda' && Endpoint=='$SNS_LAMBDA_ARN'].SubscriptionArn" \
    --output text 2>/dev/null)

# Count subscriptions
SUB_COUNT=$(echo "$ALL_SUBSCRIPTIONS" | wc -w | tr -d ' ')

if [ "$SUB_COUNT" -gt 1 ]; then
    echo "  ⚠️  Found $SUB_COUNT duplicate subscriptions, removing extras..."
    # Keep first, remove others
    FIRST=true
    for sub_arn in $ALL_SUBSCRIPTIONS; do
        if [ "$FIRST" = true ]; then
            FIRST=false
            echo "  ✓ Keeping subscription: $sub_arn"
        else
            aws sns unsubscribe --subscription-arn "$sub_arn" 2>/dev/null
            echo "  ✓ Removed duplicate: $sub_arn"
        fi
    done
elif [ "$SUB_COUNT" -eq 1 ]; then
    echo "✓ SNS subscription already exists (no duplicates)"
else
    # Create new subscription
    aws sns subscribe \
        --topic-arn $SNS_TOPIC_ARN \
        --protocol lambda \
        --notification-endpoint $SNS_LAMBDA_ARN \
        --region $REGION > /dev/null 2>&1
    echo "✓ Created SNS subscription for Lambda"
fi

# Grant SNS permission to invoke Lambda (idempotent with statement-id)
aws lambda add-permission \
    --function-name demo-sns-handler \
    --statement-id sns-invoke \
    --action lambda:InvokeFunction \
    --principal sns.amazonaws.com \
    --source-arn $SNS_TOPIC_ARN \
    --region $REGION > /dev/null 2>&1 || true

echo "✓ Connected SNS topic to Lambda"

# Create event source mapping for SQS
# Check if mapping already exists
EXISTING_MAPPING=$(aws lambda list-event-source-mappings \
    --function-name demo-sqs-processor \
    --event-source-arn $SQS_QUEUE_ARN \
    --query 'EventSourceMappings[0].UUID' \
    --output text 2>/dev/null)

if [ "$EXISTING_MAPPING" != "None" ] && [ -n "$EXISTING_MAPPING" ]; then
    echo "  Event source mapping already exists, ensuring it's enabled..."
    aws lambda update-event-source-mapping \
        --uuid $EXISTING_MAPPING \
        --enabled \
        --region $REGION > /dev/null 2>&1
    echo "✓ SQS event source mapping enabled"
else
    aws lambda create-event-source-mapping \
        --function-name demo-sqs-processor \
        --event-source-arn $SQS_QUEUE_ARN \
        --batch-size 10 \
        --enabled \
        --region $REGION > /dev/null 2>&1
    echo "✓ Created and enabled SQS event source mapping"
fi

echo "✓ Connected SQS queue to Lambda"
echo ""

echo "======================================"
echo "Serverless Demo Setup Complete!"
echo "======================================"
echo ""
echo "Resources Created:"
echo "  SNS Topic ARN: $SNS_TOPIC_ARN"
echo "  SQS Queue URL: $SQS_QUEUE_URL"
echo "  Lambda Functions:"
echo "    - demo-sns-handler"
echo "    - demo-sqs-processor"
echo "    - demo-order-processor"
echo ""
echo "Test Commands:"
echo ""
echo "1. Trigger SNS Handler:"
echo "   aws sns publish --topic-arn $SNS_TOPIC_ARN --subject 'Demo Test' --message 'Hello from SNS!'"
echo ""
echo "2. Send message to SQS:"
echo "   aws sqs send-message --queue-url $SQS_QUEUE_URL --message-body '{\"test\": \"message\"}'"
echo ""
echo "3. Invoke Order Processor:"
echo "   aws lambda invoke --function-name demo-order-processor --payload '{\"customer_name\":\"John Doe\",\"items\":[{\"name\":\"Widget\",\"qty\":2}],\"total_amount\":99.99}' response.json"
echo ""
echo "View Logs:"
echo "   aws logs tail /aws/lambda/demo-sns-handler --follow"
echo "   aws logs tail /aws/lambda/demo-sqs-processor --follow"
echo ""

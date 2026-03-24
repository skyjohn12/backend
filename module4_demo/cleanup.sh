#!/bin/bash

# Complete cleanup script for all demo resources
# Removes EC2 instances, Lambda functions, SNS, SQS, and associated resources

echo "======================================"
echo "AWS Demo Complete Cleanup"
echo "======================================"
echo ""

REGION="us-east-1"

echo "⚠️  This will delete ALL demo resources!"
echo "   - EC2 instances (Demo-Web-App)"
echo "   - Lambda functions"
echo "   - SNS topics"
echo "   - SQS queues"
echo "   - Security groups"
echo "   - IAM roles"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Part 1: Cleaning up EC2 resources..."
echo "======================================"

# Find and terminate EC2 instances
INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=Demo-Web-App" "Name=instance-state-name,Values=running,pending,stopped" \
    --query 'Reservations[0].Instances[0].InstanceId' \
    --region $REGION \
    --output text 2>/dev/null)

if [ "$INSTANCE_ID" != "None" ] && [ -n "$INSTANCE_ID" ]; then
    echo "Terminating EC2 instance: $INSTANCE_ID"
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region $REGION
    echo "✓ Instance termination initiated"
    echo "  Waiting for instance to terminate..."
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID --region $REGION 2>/dev/null || true
    echo "✓ Instance terminated"
else
    echo "  No EC2 instances found"
fi

# Delete security group
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=group-name,Values=demo-web-sg" \
    --query 'SecurityGroups[0].GroupId' \
    --region $REGION \
    --output text 2>/dev/null)

if [ "$SG_ID" != "None" ] && [ -n "$SG_ID" ]; then
    echo "Deleting security group: $SG_ID"
    # Wait a bit for instance to fully terminate
    sleep 5
    aws ec2 delete-security-group --group-id $SG_ID --region $REGION 2>/dev/null && echo "✓ Security group deleted" || echo "  (Security group may still be in use, will be cleaned up shortly)"
else
    echo "  Security group not found"
fi

echo ""
echo "Part 2: Cleaning up Lambda resources..."
echo "======================================"

# Delete Lambda functions
echo "Deleting Lambda functions..."
aws lambda delete-function --function-name demo-sns-handler --region $REGION 2>/dev/null && echo "✓ Deleted demo-sns-handler" || echo "  demo-sns-handler not found"
aws lambda delete-function --function-name demo-sqs-processor --region $REGION 2>/dev/null && echo "✓ Deleted demo-sqs-processor" || echo "  demo-sqs-processor not found"
aws lambda delete-function --function-name demo-order-processor --region $REGION 2>/dev/null && echo "✓ Deleted demo-order-processor" || echo "  demo-order-processor not found"

# Delete SNS topic
echo "Deleting SNS topic..."
SNS_TOPIC_ARN=$(aws sns list-topics --query "Topics[?contains(TopicArn, 'demo-notifications')].TopicArn" --output text)
if [ -n "$SNS_TOPIC_ARN" ]; then
    aws sns delete-topic --topic-arn $SNS_TOPIC_ARN --region $REGION
    echo "✓ Deleted SNS topic"
else
    echo "  SNS topic not found"
fi

# Delete SQS queue
echo "Deleting SQS queue..."
SQS_QUEUE_URL=$(aws sqs get-queue-url --queue-name demo-processing-queue --region $REGION --query 'QueueUrl' --output text 2>/dev/null)
if [ -n "$SQS_QUEUE_URL" ]; then
    aws sqs delete-queue --queue-url $SQS_QUEUE_URL --region $REGION
    echo "✓ Deleted SQS queue"
else
    echo "  SQS queue not found"
fi

# Delete IAM role
echo "Deleting IAM role..."
LAMBDA_ROLE_NAME="demo-lambda-execution-role"
if aws iam get-role --role-name $LAMBDA_ROLE_NAME 2>/dev/null; then
    aws iam detach-role-policy --role-name $LAMBDA_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole 2>/dev/null
    aws iam detach-role-policy --role-name $LAMBDA_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess 2>/dev/null
    aws iam detach-role-policy --role-name $LAMBDA_ROLE_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess 2>/dev/null
    aws iam delete-role --role-name $LAMBDA_ROLE_NAME
    echo "✓ Deleted IAM role"
else
    echo "  IAM role not found"
fi

echo ""
echo "Part 3: Cleaning up local files..."
echo "======================================"
rm -f part2-serverless-demo/lambda-functions/*.zip
rm -f part2-serverless-demo/response.json
echo "✓ Removed local deployment files"

echo ""
echo "======================================"
echo "Cleanup Complete!"
echo "======================================"
echo ""
echo "All demo resources have been removed."
echo ""
echo "Note: CloudWatch Logs will be automatically deleted after retention period."
echo "To delete them immediately, run:"
echo "  aws logs delete-log-group --log-group-name /aws/lambda/demo-sns-handler"
echo "  aws logs delete-log-group --log-group-name /aws/lambda/demo-sqs-processor"
echo "  aws logs delete-log-group --log-group-name /aws/lambda/demo-order-processor"
echo ""

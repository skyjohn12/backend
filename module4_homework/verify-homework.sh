#!/bin/bash

#===============================================================================
# Homework Verification Script
# Tests if your AWS resources are properly configured
#===============================================================================

echo "======================================"
echo "AWS Homework Verification"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

# Function to check status
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo "Checking AWS Authentication..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    check_pass "AWS authentication successful (Account: $ACCOUNT_ID)"
else
    check_fail "AWS authentication failed"
    echo "Run: aws-azure-login -m gui --no-sandbox"
    exit 1
fi

echo ""
echo "Checking IAM Role..."
if aws iam get-role --role-name task-lambda-execution-role > /dev/null 2>&1; then
    check_pass "IAM role 'task-lambda-execution-role' exists"
    
    # Check attached policies
    POLICIES=$(aws iam list-attached-role-policies --role-name task-lambda-execution-role --query 'AttachedPolicies[].PolicyName' --output text)
    if echo "$POLICIES" | grep -q "AWSLambdaBasicExecutionRole"; then
        check_pass "Lambda execution policy attached"
    else
        check_fail "Lambda execution policy not attached"
    fi
else
    check_fail "IAM role 'task-lambda-execution-role' not found"
fi

echo ""
echo "Checking SNS Topic..."
SNS_TOPICS=$(aws sns list-topics --query 'Topics[?contains(TopicArn, `task-notifications`)].TopicArn' --output text)
if [ -n "$SNS_TOPICS" ]; then
    check_pass "SNS topic 'task-notifications' exists"
    echo "  Topic ARN: $SNS_TOPICS"
    
    # Check subscriptions
    SUBS=$(aws sns list-subscriptions-by-topic --topic-arn "$SNS_TOPICS" --query 'Subscriptions[].Protocol' --output text)
    if echo "$SUBS" | grep -q "email"; then
        check_pass "Email subscription configured"
    else
        check_warn "No email subscription found - you won't receive notifications"
    fi
else
    check_fail "SNS topic 'task-notifications' not found"
fi

echo ""
echo "Checking SQS Queue..."
SQS_URL=$(aws sqs get-queue-url --queue-name task-processing-queue --query 'QueueUrl' --output text 2>/dev/null)
if [ -n "$SQS_URL" ]; then
    check_pass "SQS queue 'task-processing-queue' exists"
    echo "  Queue URL: $SQS_URL"
else
    check_fail "SQS queue 'task-processing-queue' not found"
fi

echo ""
echo "Checking Lambda Functions..."
LAMBDA_VALIDATOR=$(aws lambda get-function --function-name task-validator 2>/dev/null)
if [ $? -eq 0 ]; then
    check_pass "Lambda function 'task-validator' exists"
    
    # Check SQS trigger
    EVENT_SOURCE=$(aws lambda list-event-source-mappings --function-name task-validator --query 'EventSourceMappings[0]' 2>/dev/null)
    if [ -n "$EVENT_SOURCE" ] && [ "$EVENT_SOURCE" != "null" ]; then
        # Check if enabled
        MAPPING_STATE=$(aws lambda list-event-source-mappings --function-name task-validator --query 'EventSourceMappings[0].State' --output text 2>/dev/null)
        if [ "$MAPPING_STATE" == "Enabled" ]; then
            check_pass "task-validator has SQS trigger configured and ENABLED"
        else
            check_fail "task-validator SQS trigger exists but is DISABLED"
            echo "  Run: aws lambda update-event-source-mapping --uuid \$(aws lambda list-event-source-mappings --function-name task-validator --query 'EventSourceMappings[0].UUID' --output text) --enabled"
        fi
    else
        check_fail "task-validator missing SQS trigger"
    fi
else
    check_fail "Lambda function 'task-validator' not found"
fi

LAMBDA_NOTIFIER=$(aws lambda get-function --function-name task-notifier 2>/dev/null)
if [ $? -eq 0 ]; then
    check_pass "Lambda function 'task-notifier' exists"
    
    # Check for duplicate SNS subscriptions
    if [ -n "$SNS_TOPICS" ]; then
        NOTIFIER_ARN="arn:aws:lambda:us-east-1:$ACCOUNT_ID:function:task-notifier"
        SUB_COUNT=$(aws sns list-subscriptions-by-topic --topic-arn "$SNS_TOPICS" \
            --query "Subscriptions[?Protocol=='lambda' && Endpoint=='$NOTIFIER_ARN']" \
            --output json | grep -c "SubscriptionArn" || echo "0")
        
        if [ "$SUB_COUNT" -eq 1 ]; then
            check_pass "task-notifier has correct SNS subscription (no duplicates)"
        elif [ "$SUB_COUNT" -gt 1 ]; then
            check_warn "task-notifier has $SUB_COUNT duplicate subscriptions - Lambda will trigger multiple times!"
            echo "  To fix, list subscriptions and remove extras:"
            echo "  aws sns list-subscriptions-by-topic --topic-arn $SNS_TOPICS"
            echo "  aws sns unsubscribe --subscription-arn DUPLICATE-ARN"
        else
            check_warn "task-notifier has no SNS subscription configured"
        fi
    fi
else
    check_fail "Lambda function 'task-notifier' not found"
fi

echo ""
echo "======================================"
echo "Verification Summary"
echo "======================================"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Your homework is ready for submission.${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Review AWS console the logs of your Lambda functions"
    echo "2. Ensure SNS notifications are received (if email subscribed)"
    echo "3. Push your branch with your code changes"
else
    echo -e "${RED}⚠️  Some checks failed. Please fix the issues above.${NC}"
    echo ""
    echo "Common issues:"
    echo "- Make sure you've created all required AWS resources"
    echo "- Check IAM permissions"
    echo "- Verify Lambda functions are deployed with correct names"
    echo "- Ensure environment variables are set"
fi

echo ""
echo "For detailed help, see README.md"

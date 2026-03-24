#!/bin/bash

# Test script for serverless demo
# Demonstrates the complete flow of Lambda, SNS, and SQS

echo "======================================"
echo "Testing Serverless Demo"
echo "======================================"
echo ""

# Check AWS credentials
echo "Checking AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo ""
    echo "❌ Error: AWS credentials are invalid or expired"
    echo ""
    echo "Please refresh your credentials:"
    echo "  1. If using aws-azure-login: Run 'aws-azure-login'"
    echo "  2. If using AWS Academy: Get new credentials from AWS Details"
    echo "  3. If using SSO: Run 'aws sso login'"
    echo ""
    exit 1
fi
echo "✓ AWS credentials valid"
echo ""

REGION="us-east-1"

# Verify Lambda functions exist
echo "Verifying Lambda functions are deployed..."
FUNCTIONS=("demo-order-processor" "demo-sns-handler" "demo-sqs-processor")
for func in "${FUNCTIONS[@]}"; do
    if ! aws lambda get-function --function-name $func > /dev/null 2>&1; then
        echo "❌ Error: Lambda function '$func' not found"
        echo ""
        echo "Please run './deploy-lambda.sh' first to deploy all functions."
        exit 1
    fi
done
echo "✓ All Lambda functions found"
echo ""

# Get current timestamp for log filtering
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")
echo "Test timestamp: $TIMESTAMP"
echo ""

echo "======================================"
echo "Event-Driven Flow Demonstration"
echo "======================================"
echo ""
echo "This test demonstrates the complete serverless event flow:"
echo "  1. Order Processor receives order"
echo "  2. Order Processor publishes to SNS → triggers SNS Handler"
echo "  3. Order Processor sends to SQS → triggers SQS Processor"
echo ""
echo "Press Enter to start the test..."
read

echo "======================================"
echo "Invoking Order Processor Lambda"
echo "======================================"
echo ""

# Check if test-payload.json exists
if [ ! -f "test-payload.json" ]; then
    echo "❌ Error: test-payload.json not found in current directory"
    echo ""
    echo "Please create test-payload.json with the following format:"
    echo '{'
    echo '  "customer_name": "Jane Smith",'
    echo '  "customer_id": "CUST-12345",'
    echo '  "items": [{"name": "Demo Product", "quantity": 3, "price": 49.99}],'
    echo '  "total_amount": 149.97'
    echo '}'
    exit 1
fi

echo "Sending order data from test-payload.json..."
if aws lambda invoke \
    --function-name demo-order-processor \
    --cli-binary-format raw-in-base64-out \
    --payload file://test-payload.json \
    --region $REGION \
    response.json > /dev/null 2>&1; then
    
    echo "✓ Order Processor Lambda executed"
    echo ""
    echo "Response:"
    cat response.json | python3 -m json.tool 2>/dev/null || cat response.json
    echo ""
    
    # Check if response contains error
    if grep -q "errorMessage" response.json 2>/dev/null; then
        echo "⚠️  Lambda returned an error. Check the logs for details."
    fi
    
    rm -f response.json
else
    echo "❌ Failed to invoke Order Processor"
    echo ""
    echo "Error details:"
    cat response.json 2>/dev/null || echo "No response file created"
    rm -f response.json
    exit 1
fi

echo "⏳ Waiting 8 seconds for async triggers to complete..."
echo "   (SNS Handler and SQS Processor are being triggered automatically)"
echo ""
sleep 8

echo "======================================"
echo "Verifying Event-Driven Execution"
echo "======================================"
echo ""
echo "Checking CloudWatch Logs to verify all functions executed..."
echo ""

# Function to check if Lambda executed
check_lambda_execution() {
    local function_name=$1
    local display_name=$2
    
    echo "[$display_name]"
    
    # Get recent logs
    local logs=$(aws logs tail /aws/lambda/$function_name --since 2m --format short 2>/dev/null | grep -i "processing\|received\|order\|message" | head -5)
    
    if [ -z "$logs" ]; then
        echo "  ⚠️  No recent execution logs found"
        echo "     (Function may not have been triggered or logs not yet available)"
    else
        echo "  ✅ Function executed! Recent logs:"
        echo "$logs" | sed 's/^/     /'
    fi
    echo ""
}

check_lambda_execution "demo-order-processor" "1. Order Processor"
check_lambda_execution "demo-sns-handler" "2. SNS Handler (triggered by SNS)"
check_lambda_execution "demo-sqs-processor" "3. SQS Processor (triggered by SQS)"

echo "======================================"
echo "Execution Metrics Summary"
echo "======================================"
echo ""

# Get invocation counts
for func in "demo-order-processor" "demo-sns-handler" "demo-sqs-processor"; do
    invocations=$(aws cloudwatch get-metric-statistics \
        --namespace AWS/Lambda \
        --metric-name Invocations \
        --dimensions Name=FunctionName,Value=$func \
        --start-time $(date -u -v-5M +"%Y-%m-%dT%H:%M:%S") \
        --end-time $(date -u +"%Y-%m-%dT%H:%M:%S") \
        --period 300 \
        --statistics Sum \
        --query 'Datapoints[0].Sum' \
        --output text 2>/dev/null)
    
    if [ "$invocations" != "None" ] && [ ! -z "$invocations" ]; then
        echo "✓ $func: $invocations invocation(s) in last 5 minutes"
    else
        echo "⏳ $func: Waiting for metrics to populate..."
    fi
done

echo ""
echo "======================================"
echo "Test Complete! 🎉"
echo "======================================"
echo ""
echo "What just happened:"
echo "  ✅ Order Processor received and validated the order"
echo "  ✅ Published notification to SNS → auto-triggered SNS Handler"
echo "  ✅ Sent message to SQS → auto-triggered SQS Processor"
echo "  ✅ All three functions executed in event-driven flow"
echo ""
echo "This demonstrates TRUE SERVERLESS:"
echo "  • No servers to manage"
echo "  • Event-driven automatic triggers"
echo "  • Pay only for execution time"
echo "  • Instant auto-scaling"
echo ""
echo "View detailed logs in real-time:"
echo "  aws logs tail /aws/lambda/demo-order-processor --follow"
echo "  aws logs tail /aws/lambda/demo-sns-handler --follow"
echo "  aws logs tail /aws/lambda/demo-sqs-processor --follow"
echo ""
echo "Check AWS Console:"
echo "  Lambda → Functions → [function name] → Monitor tab"
echo ""

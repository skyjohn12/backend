# Part 2: Serverless Architecture Demo (FaaS - Function as a Service)

## Overview
This demo showcases AWS Lambda functions integrated with SNS and SQS, demonstrating **Serverless/FaaS (Function as a Service)** architecture with event-driven order processing.

## What is Serverless/FaaS?

**Key Characteristics:**
- **No server management** - AWS handles all infrastructure
- **Event-driven execution** - Functions run only when triggered
- **Pay-per-execution** - Charged only for actual compute time (milliseconds)
- **Auto-scaling** - From zero to thousands of concurrent executions automatically
- **Stateless functions** - Each invocation is independent

**Serverless vs Traditional PaaS:**
- **Traditional PaaS** (like Elastic Beanstalk): Manages infrastructure but applications run continuously (idle cost)
- **Serverless/FaaS**: Zero idle cost, functions only exist during execution

## What's Demonstrated
- Event-driven order processing with AWS Lambda
- SNS for pub/sub notifications
- SQS for reliable message queuing
- Automatic function triggering (no manual invocation)

## Architecture

```
Order Processor Lambda ──► SNS Topic ──► SNS Handler Lambda
         │                                        │
         └──────────► SQS Queue ◄────────────────┘
                          │
                          └──► SQS Processor Lambda
```

### Components
1. **Order Processor Lambda**: Receives orders and initiates processing
2. **SNS Topic**: Broadcasts notifications about new orders
3. **SNS Handler Lambda**: Triggered by SNS notifications
4. **SQS Queue**: Queues orders for processing
5. **SQS Processor Lambda**: Processes orders from the queue

## Files in This Demo
- `lambda-functions/sns_handler.py` - Lambda triggered by SNS
- `lambda-functions/sqs_processor.py` - Lambda triggered by SQS
- `lambda-functions/order_processor.py` - Main order processing Lambda
- `deploy-lambda.sh` - Automated deployment script
- `test-lambda.sh` - Test script to trigger all functions
- `cleanup-lambda.sh` - Resource cleanup script

## Quick Start

### Automated Deployment
```bash
cd part2-serverless-demo
chmod +x deploy-lambda.sh
./deploy-lambda.sh
```

The script will:
1. Create IAM role for Lambda execution
2. Create SNS topic for notifications
3. Create SQS queue for message processing
4. Deploy all three Lambda functions
5. Configure triggers and permissions
6. Display test commands

**Deployment takes 1-2 minutes.**

## Testing the Demo

### Run Automated Tests (Recommended)
```bash
chmod +x test-lambda.sh
./test-lambda.sh
```

**What it does:**
- Invokes Order Processor Lambda with sample order data
- Order Processor automatically triggers SNS Handler and SQS Processor
- Waits for async processing to complete
- Verifies all three functions executed via CloudWatch logs
- Shows metrics and invocation counts

**This demonstrates the complete event-driven serverless flow!**

### Manual Testing (Alternative Methods)

**Note:** The automated test script above is recommended as it demonstrates the complete integrated flow. The tests below are for individual component testing only.

#### Test 1: Invoke Order Processor (Best for Demo)sor (Best for Demo)
```bash
# Create payload file
cat > order-payload.json << 'EOF'
{
  "customer_name": "Jane Smith",
  "customer_id": "CUST-12345",
  "items": [
    {"name": "Widget A", "quantity": 2, "price": 29.99}
  ],
  "total_amount": 59.98
}
EOF

# Invoke Lambda
aws lambda invoke \
    --function-name demo-order-processor \
    --cli-binary-format raw-in-base64-out \
    --payload file://order-payload.json \
    response.json

# View response
cat response.json | python3 -m json.tool
```

**What happens:**
- Order Processor validates the order and generates order ID
- Publishes notification to SNS → automatically triggers SNS Handler
- Sends message to SQS → automatically triggers SQS Processor
- All three functions execute in event-driven flow
- Check CloudWatch logs to see all executions

#### Test 2: Direct SNS Notification (Individual Component Test)
```bash
aws sns publish \
    --topic-arn arn:aws:sns:us-east-1:YOUR_ACCOUNT:demo-notifications \
    --subject "Direct SNS Test" \
    --message "Testing SNS Handler directly"
```

**What happens:**
- SNS publishes the message directly
- SNS Handler Lambda is automatically triggered
- View logs: `aws logs tail /aws/lambda/demo-sns-handler --since 2m`

#### Test 3: Direct SQS Message (Individual Component Test)
```bash
aws sqs send-message \
    --queue-url https://sqs.us-east-1.amazonaws.com/YOUR_ACCOUNT/demo-processing-queue \
    --message-body '{"order_id":"TEST-001","customer":"Demo User","amount":99.99}'
```

**What happens:**
- Message is added to SQS queue directly
- SQS Processor Lambda is automatically triggered
- View logs: `aws logs tail /aws/lambda/demo-sqs-processor --since 2m`

**Important:** Tests 2 and 3 bypass the Order Processor and only test individual components. For demo purposes, use Test 1 or the automated test script to show the complete integrated flow.

## View Lambda Logs

```bash
# Real-time logs
aws logs tail /aws/lambda/demo-sns-handler --follow
aws logs tail /aws/lambda/demo-sqs-processor --follow
aws logs tail /aws/lambda/demo-order-processor --follow

# Recent logs (last 5 minutes)
aws logs tail /aws/lambda/demo-sns-handler --since 5m
```

## Demo Talking Points

### During Setup (2 minutes)
- "We're deploying Lambda functions - truly serverless compute"
- "No servers to manage, pay only for execution time (per millisecond)"
- "Auto-scales from zero to thousands of requests automatically"
- "This is FaaS/Serverless - AWS manages everything, you only write functions"

### Architecture Explanation (3 minutes)
- "SNS provides pub/sub messaging - broadcast to multiple subscribers"
- "SQS provides reliable queuing - processes messages sequentially"
- "Lambda functions are event-driven - triggered automatically by events"
- "This is fully managed serverless - no servers, no patching, no scaling configuration"

### Live Demo (3 minutes)
1. **Run test-lambda.sh**: Shows complete event-driven flow
2. **Invoke Order Processor**: One function triggers two others automatically
3. **View CloudWatch Logs**: Show all three functions executed
4. **Highlight metrics**: Show invocation count, duration, costs
5. **Key point**: Emphasize automatic triggering - no manual invocation of SNS/SQS handlers needed

### Cost Comparison (1 minute)
- "Lambda Free Tier: 1M requests/month free"
- "Typical demo cost: < $0.01"
- "Production costs: only pay for actual usage"
- "Compare to EC2: no idle server costs"

## Monitoring in AWS Console

- **Lambda**: Functions → [function name] → Monitor tab (invocations, duration, errors)
- **SNS**: Topics → demo-notifications (subscriptions, published messages)
- **SQS**: Queues → demo-processing-queue (message count, age)

## Cleanup
```bash
./cleanup-lambda.sh
```

This removes all Lambda functions, SNS topics, SQS queues, and IAM roles created during deployment.

## Troubleshooting

**AWS credentials expired:**
- Run `aws-azure-login` (or refresh via AWS Academy/SSO)
- Scripts now check credentials automatically

**Lambda not triggered:**
- Check CloudWatch logs for errors
- Verify IAM role has Lambda, SNS, SQS permissions
- Wait 10 seconds after deployment for permissions to propagate

## Time Budget
- **Setup explanation**: 2 minutes
- **Execute deployment**: 2 minutes
- **Demo live triggers**: 3 minutes
- **Show logs and monitoring**: 2 minutes
- **Total**: 9 minutes

## Cloud Service Model Comparison

| Aspect | IaaS (EC2) | PaaS Hybrid (Elastic Beanstalk) | Serverless/FaaS (Lambda) |
|--------|------------|--------------------------------|--------------------------|
| **Abstraction Level** | Infrastructure | Platform | Function |
| **Server Management** | You manage VMs | AWS manages platform | No servers at all |
| **Scaling** | Manual/ASG | Auto-scaling | Instant auto-scaling |
| **Pricing Model** | Hourly (24/7) | Hourly (app runs continuously) | Per-execution (ms billing) |
| **Patching** | Your responsibility | AWS handles platform | Fully AWS managed |
| **Idle Costs** | Yes (always running) | Yes (platform always on) | **No (pay only when executing)** |
| **Setup Complexity** | High | Medium | Low |
| **Control** | Full control | Moderate control | Limited control |
| **Best For** | Custom infrastructure | Web apps, APIs | Event-driven workloads |

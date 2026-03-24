# AWS Cloud Computing Demo - Presentation Script

## 20-Minute Demo Script with Timing

### Introduction (1 minute)

**[Slide: Title Slide]**
"Today, we'll explore cloud computing through a live AWS demonstration. We'll cover two Platform as a Service approaches - managed platform deployment and serverless architecture - plus Software as a Service tools we use along the way."

**Key Points:**
- PaaS Hybrid: Elastic Beanstalk + S3 (managed platform)
- Serverless/FaaS: Lambda + SNS + SQS (event-driven functions)
- SaaS: AWS Console, CloudWatch (fully managed services)

---

## Part 1: PaaS Hybrid - Elastic Beanstalk Deployment (8 minutes)

### Setup and Explanation (3 minutes)

**[Slide: PaaS Hybrid Concept]**
"Let's start with Elastic Beanstalk - a Platform as a Service that abstracts infrastructure management. With Elastic Beanstalk, AWS manages the EC2 instances, load balancing, scaling, and patching, while we focus on our application code."

**[Switch to Terminal]**
```bash
cd part1-ec2-demo
```

"I've prepared a Flask web application with S3 file storage. Let's deploy it to Elastic Beanstalk."

**Show the code briefly:**
```bash
cat app.py
```

**Talking points while showing code:**
- "Simple Python Flask application with S3 integration"
- "Will run on Elastic Beanstalk - a managed platform"
- "We write code, AWS handles infrastructure, scaling, and patching"

### Deploy to Elastic Beanstalk (3 minutes)

**[Terminal]**
```bash
./deploy-beanstalk.sh
```

**While script runs, explain:**
1. "Creating S3 bucket for file storage - secured with PRIVATE access"
2. "Packaging application with dependencies"
3. "Creating Elastic Beanstalk environment"
4. "AWS automatically provisions EC2, load balancer, and auto-scaling"
5. "Security groups restricted to your IP for compliance"

**Key PaaS characteristics to mention:**
- ✓ Platform manages infrastructure automatically
- ✓ Built-in load balancing and auto-scaling
- ✓ AWS handles patching and updates
- ✓ Pay for underlying EC2 instances (hourly)
- ✓ Focus on code, not infrastructure management

### Show Running Application (2 minutes)

**[Browser]**
Open: URL from script output (e.g., `http://demo-webapp-env.us-east-1.elasticbeanstalk.com`)

**Point out on screen:**
- "Application running on Elastic Beanstalk - AWS manages the EC2 instance, Nginx proxy, health checks"
- "Upload a file - stored in PRIVATE S3 bucket (Slalom InfoSec compliant)"
- "Files accessed via pre-signed URLs (1-hour expiry) - no public S3 access"
- "Instance info shows hostname and IP - proves it's running on real infrastructure"
- "This is PaaS Hybrid - AWS manages platform, we manage code"

**Key difference vs Serverless:**
"Notice the app is ALWAYS running - we pay hourly for the EC2 instance. In Part 2, we'll see serverless where functions only run when triggered."

---

## Part 2: Serverless/FaaS Architecture (9 minutes)

### Introduction to Serverless (2 minutes)

**[Slide: Serverless/FaaS Concept]**
"Now let's move to true Serverless - also called FaaS (Function as a Service). While it's technically a subset of PaaS, serverless has unique characteristics: no servers to manage, event-driven execution, and pay-per-millisecond billing."

**[Terminal]**
```bash
cd ../part2-serverless-demo
```

**Architecture explanation:**
"We'll demonstrate three Lambda functions integrated with SNS and SQS:
1. Order Processor - receives and validates orders
2. SNS Handler - triggered by notifications
3. SQS Processor - processes queued messages"

**[Show architecture diagram on slide]**
- "Event-driven architecture"
- "No servers to manage"
- "Auto-scales automatically"
- "Pay only for execution time"

### Deploy Lambda Functions (2 minutes)

**[Terminal]**
```bash
./deploy-lambda.sh
```

**While script runs, explain:**
1. "Creating IAM role - defines what Lambda can access"
2. "Creating SNS topic - for pub/sub notifications"
3. "Creating SQS queue - for reliable message processing"
4. "Deploying Lambda functions - just uploading code"
5. "Configuring triggers - no manual setup needed"

**Key PaaS characteristics:**
- ✓ No server management
- ✓ Automatic scaling
- ✓ Pay per execution (not idle time)
- ✓ Built-in monitoring
- ✓ AWS handles patching, availability

### Live Demonstration (3 minutes)

**Run the automated test (recommended):**
```bash
./test-lambda.sh
```

**[As script runs, explain the flow]**

**What's happening:**
1. "Test invokes Order Processor Lambda with sample order"
2. "Order Processor validates order, generates order ID"
3. "Automatically publishes to SNS → triggers SNS Handler Lambda"
4. "Automatically sends to SQS → triggers SQS Processor Lambda"
5. "All three functions execute in event-driven flow"

**Key points to emphasize:**
- "Notice: We only invoked ONE function"
- "The other two triggered AUTOMATICALLY - that's event-driven architecture"
- "No servers to manage - functions exist only during execution"
- "Check the logs - you'll see all three functions executed"
- "This took milliseconds - instant auto-scaling"

**[Show CloudWatch Logs if time permits]**
```bash
aws logs tail /aws/lambda/demo-order-processor --since 2m
aws logs tail /aws/lambda/demo-sns-handler --since 2m
aws logs tail /aws/lambda/demo-sqs-processor --since 2m
```

### Architecture Benefits (2 minutes)

**[Slide: PaaS Hybrid vs Serverless Comparison]**

| Aspect | PaaS Hybrid (Elastic Beanstalk) | Serverless/FaaS (Lambda) |
|--------|--------------------------------|---------------------------|
| **Management** | AWS manages platform, you manage code | AWS manages everything |
| **Execution Model** | Always-on application | Event-driven functions |
| **Scaling** | Auto-scaling (configure min/max) | Instant auto-scaling (0 to 1000s) |
| **Pricing** | Hourly (EC2 instance cost) | Per-execution (millisecond billing) |
| **Idle Cost** | Yes (instances always running) | **No (zero cost when idle)** |
| **Setup Time** | 5-7 minutes | 2 minutes |
| **Best For** | Web apps, continuous services | Event-driven, sporadic workloads |

**Cost Example:**
"For this demo:
- Elastic Beanstalk: ~$7.50/month for t3.micro (if left running)
- Lambda: ~$0.000001 per execution = pennies for thousands of requests
- Both eligible for AWS Free Tier!"

---

## Conclusion (2 minutes)

### SaaS Quick Mention

**[Slide: SaaS Examples]**
"We've been using SaaS throughout this demo:
- AWS Console - web interface for management
- CloudWatch - monitoring and logging
- No installation, no management, just use the service"

### Summary

**[Slide: Cloud Service Models]**

**PaaS Hybrid (Elastic Beanstalk + S3):**
- AWS manages platform infrastructure (EC2, load balancer, scaling)
- You manage application code and configuration
- Application runs continuously (idle cost)
- Best for: Web applications, APIs with steady traffic
- Example: E-commerce sites, REST APIs, web portals

**Serverless/FaaS (Lambda + SNS + SQS):**
- AWS manages everything - zero server management
- Event-driven execution - functions run only when triggered
- Pay per execution (millisecond billing, no idle cost)
- Best for: Event-driven apps, sporadic workloads, microservices
- Example: File processing, IoT backends, scheduled tasks, webhooks

**SaaS:**
- Fully managed software
- No infrastructure or platform management
- Best for: Standard business applications
- Example: Salesforce, Office 365, Gmail

### When to Use Each

**[Slide: Decision Guide]**
- **Use Elastic Beanstalk when:** Building web apps with continuous traffic, need managed platform, want moderate control
- **Use Lambda when:** Event-driven workloads, sporadic/unpredictable traffic, want zero server management and pay-per-use
- **Use SaaS when:** Standard functionality meets needs, no customization required

**Cost consideration:**
- Elastic Beanstalk: Better for consistent traffic (fixed cost)
- Lambda: Better for sporadic traffic (variable cost, zero when idle)

### Demo Wrap-up

**[Terminal]**
"Let me show both architectures side by side:"

**[Browser: Elastic Beanstalk App]** - `http://demo-webapp-env.elasticbeanstalk.com`
**[Terminal: Lambda Metrics]** - CloudWatch dashboard or test output

"Both are PaaS, but different approaches:
- Elastic Beanstalk: Managed platform, always-on, hourly cost
- Lambda: Serverless functions, on-demand, pay-per-execution

**Key insight:** Choose based on traffic patterns and cost model."

---

## Q&A (Time Permitting)

**Common Questions & Answers:**

**Q: "What about data persistence?"**
A: "Both models support databases. EC2 can host databases directly. Lambda connects to managed databases like RDS or DynamoDB."

**Q: "How do costs compare at scale?"**
A: "Depends on usage patterns. Lambda wins for sporadic workloads. EC2 can be cheaper for consistent, high-traffic applications."

**Q: "Can you mix PaaS and Serverless?"**
A: "Absolutely! Most architectures are hybrid. For example, Elastic Beanstalk for the web app, Lambda for background processing, RDS for database."

**Q: "What about cold starts with Lambda?"**
A: "Lambda has ~100-300ms cold start. For most use cases, this is acceptable. Use provisioned concurrency for latency-sensitive apps."

---

## Cleanup

**[Important: After Demo]**
```bash
./cleanup.sh
```

"Always clean up demo resources to avoid charges!"

---

## Backup Slides / Extra Content

### Detailed Cost Breakdown

**EC2 t2.micro:**
- On-Demand: $0.0116/hour
- Per month: ~$8.50 (if running 24/7)
- Reserved Instance: ~$4/month (1-year commitment)

**Lambda:**
- First 1M requests: FREE
- After: $0.20 per 1M requests
- Compute: $0.0000166667 per GB-second
- Example: 1M executions at 512MB, 1s each = $8.33/month

### Real-World Use Cases

**PaaS Hybrid (Elastic Beanstalk):**
- Web applications with steady traffic
- REST APIs serving mobile apps
- E-commerce platforms
- Content management systems
- Applications needing moderate platform control

**Serverless (Lambda):**
- Image/video processing pipelines
- Real-time file processing
- Scheduled tasks and cron jobs
- API backends with variable traffic
- IoT data processing

---

## Presenter Notes

### Timing Checkpoints
- **5 minutes:** Should be showing EC2 application running
- **10 minutes:** Should have started Lambda deployment
- **15 minutes:** Should be demonstrating live Lambda triggers
- **18 minutes:** Should be in comparison/conclusion
- **20 minutes:** Open for questions

### Key Messages to Drive Home
1. **PaaS Hybrid = Managed Platform** - AWS handles infrastructure, you handle code
2. **Serverless = Zero Management** - AWS handles everything, you only write functions
3. **Cost Model Matters** - Always-on vs pay-per-use changes economics
4. **Choose by Traffic Pattern** - Consistent traffic → Elastic Beanstalk, Sporadic → Lambda

### Troubleshooting During Demo

**If Elastic Beanstalk app doesn't load:**
- "Elastic Beanstalk deployment takes 5-7 minutes"
- Show environment health in AWS Console
- Check logs: `eb logs` or AWS Console → Elastic Beanstalk → Logs

**If Lambda doesn't trigger:**
- "Let's check CloudWatch Logs directly"
- Open AWS Console and show Lambda configuration

**If time runs short:**
- Skip detailed code walkthrough
- Focus on live demos and comparisons
- Show final architecture diagrams

### Energy and Engagement
- Make it interactive: "Let's see what happens when..."
- Show enthusiasm about serverless benefits
- Acknowledge trade-offs honestly
- Use analogies: "Elastic Beanstalk is like a managed apartment, Lambda is like a hotel room - pay only when you're there"

---

## Post-Demo Resources

Share with audience:
```
GitHub Repository: [your-repo-url]
AWS Documentation: aws.amazon.com/documentation
AWS Free Tier: aws.amazon.com/free
```

**Next Steps for Learners:**
1. Sign up for AWS Free Tier
2. Follow this demo step-by-step
3. Explore AWS tutorials
4. Build a simple serverless API
5. Try AWS Certified Cloud Practitioner exam

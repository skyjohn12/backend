# Architecture Diagrams & Visual Guides

## Demo Architecture Overview

```
┌──────────────────────────────────────────────────────────────────────┐
│                    AWS Cloud Computing Demo                           │
│                                                                       │
│  ┌───────────────────────────┐   ┌──────────────────────────────┐  │
│  │   Part 1: PaaS Hybrid     │   │   Part 2: Serverless/FaaS    │  │
│  │   Elastic Beanstalk + S3  │   │   Lambda + SNS + SQS         │  │
│  │   (Managed Platform)      │   │   (Event-Driven Functions)   │  │
│  └───────────────────────────┘   └──────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Part 1: PaaS Hybrid Architecture (Elastic Beanstalk + S3)

### High-Level View
```
                    ┌─────────────────────┐
                    │   User's Browser    │
                    └──────────┬──────────┘
                               │
                    HTTP       │       Pre-signed URLs
                  (Upload)     │       (Download, 1hr expiry)
                               │
                    ┌──────────▼──────────────────────────────┐
                    │    AWS Elastic Beanstalk (PaaS)         │
                    │  ┌────────────────────────────────────┐ │
                    │  │  Nginx Proxy (20MB file limit)     │ │
                    │  └──────────────┬─────────────────────┘ │
                    │  ┌──────────────▼─────────────────────┐ │
                    │  │  Flask App (Python 3.9)            │ │
                    │  │  - File upload handler             │ │
                    │  │  - Instance info API               │ │
                    │  │  - S3 integration (boto3)          │ │
                    │  └──────────────┬─────────────────────┘ │
                    │  ┌──────────────▼─────────────────────┐ │
                    │  │  EC2 Instance (t3.micro)           │ │
                    │  │  + IAM Instance Profile            │ │
                    │  └──────────────┬─────────────────────┘ │
                    └─────────────────┼───────────────────────┘
                                      │
                              IAM Role (S3 Access)
                                      │
                    ┌─────────────────▼───────────────────────┐
                    │      Amazon S3 Bucket (Private)         │
                    │  - BlockPublicAccess: Enabled           │
                    │  - Access: IAM role only                │
                    │  - Files served via pre-signed URLs     │
                    └─────────────────────────────────────────┘

AWS Manages:
├── Platform (EC2, Load Balancer, Auto Scaling)
├── Operating System patching
├── Runtime environment updates
└── Health monitoring & recovery

You Manage:
├── Application Code (Flask)
└── Configuration (.ebextensions)

### Elastic Beanstalk Component Breakdown
```
┌─────────────────────────────────────────────────────┐
│          Elastic Beanstalk Environment              │
├─────────────────────────────────────────────────────┤
│ Platform: Python 3.9                                │
│ Instance Type: t3.micro (InfoSec approved)          │
│ Deployment: Single instance (demo mode)             │
│ Region: us-east-1                                   │
└─────────────────────────────────────────────────────┘
         │
         ├── Nginx Proxy Layer
         │   ├── Reverse proxy
         │   ├── 20MB file size limit
         │   └── SSL/TLS termination (if configured)
         │
         ├── Application Layer
         │   ├── Flask 3.0.0
         │   ├── Gunicorn WSGI server
         │   └── boto3 (AWS SDK)
         │
         ├── Application Files
         │   ├── app.py (Flask routes)
         │   ├── templates/index.html
         │   ├── requirements.txt
         │   └── .ebextensions/python.config
         │
         └── AWS Integrations
             ├── IAM Instance Profile
             ├── S3 bucket access
             ├── CloudWatch Logs
             └── Health monitoring

---

## Part 2: Serverless/FaaS Architecture (Lambda + SNS + SQS)

### Complete Serverless Flow
```
┌────────────────────────────────────────────────────────────────┐
│                      Serverless Architecture                    │
└────────────────────────────────────────────────────────────────┘

   ┌─────────────────┐
   │  Order Request  │  (Manual trigger or API Gateway)
   └────────┬────────┘
            │
            ▼
   ┌──────────────────────────────────────┐
   │  Lambda: Order Processor             │
   │  - Validates order                   │
   │  - Generates order ID                │
   └────────┬─────────────────────┬───────┘
            │                     │
            │ Publish             │ Send Message
            ▼                     ▼
   ┌────────────────┐    ┌──────────────────┐
   │  SNS Topic     │    │   SQS Queue      │
   │  (Pub/Sub)     │    │   (Message       │
   │                │    │    Queue)        │
   └────────┬───────┘    └─────────┬────────┘
            │                      │
            │ Trigger              │ Trigger (Polling)
            ▼                      ▼
   ┌────────────────┐    ┌──────────────────┐
   │  Lambda:       │    │  Lambda:         │
   │  SNS Handler   │    │  SQS Processor   │
   │  - Processes   │    │  - Processes     │
   │    notification│    │    queued        │
   │  - Logs event  │    │    messages      │
   │  - Forwards to │    │  - Sends         │
   │    SQS         │    │    notifications │
   └────────────────┘    └──────────────────┘
```

### Lambda Function Details
```
┌────────────────────────────────────────────────┐
│          Lambda Function (Serverless)          │
├────────────────────────────────────────────────┤
│ Runtime: Python 3.9                            │
│ Memory: 128 MB (default)                       │
│ Timeout: 30 seconds                            │
│ Execution Role: demo-lambda-execution-role     │
├────────────────────────────────────────────────┤
│ Triggers:                                      │
│ ├── SNS Topic Subscription                    │
│ ├── SQS Event Source Mapping                  │
│ └── Direct Invocation (API Gateway)           │
├────────────────────────────────────────────────┤
│ Permissions:                                   │
│ ├── CloudWatch Logs (Write)                   │
│ ├── SNS (Publish)                             │
│ └── SQS (Send/Receive/Delete Messages)        │
└────────────────────────────────────────────────┘

AWS Manages:
├── Server provisioning
├── Operating system
├── Runtime environment
├── Scaling (0 to 1000s)
├── Fault tolerance
├── Availability
└── Patching & updates

You Manage:
└── Application code only!
```

---

## SNS (Simple Notification Service) Architecture

```
                    ┌──────────────────┐
                    │    SNS Topic     │
                    │ "demo-notifications"
                    └────────┬─────────┘
                             │
                    Publish  │  Fan-out (1-to-Many)
                             │
          ┌──────────────────┼──────────────────┐
          ▼                  ▼                  ▼
   ┌─────────────┐    ┌─────────────┐   ┌─────────────┐
   │  Lambda     │    │  Email      │   │  SMS        │
   │  Function   │    │  Subscriber │   │  Subscriber │
   │             │    │  (optional) │   │  (optional) │
   └─────────────┘    └─────────────┘   └─────────────┘

Features:
├── Publish once, deliver to many
├── Push-based delivery
├── Supports multiple protocols
│   ├── Lambda
│   ├── Email
│   ├── SMS
│   ├── HTTP/HTTPS
│   └── SQS
└── Immediate delivery (< 1 second)
```

---

## SQS (Simple Queue Service) Architecture

```
                    ┌──────────────────┐
                    │    SQS Queue     │
   Producers        │ "demo-processing-queue"    Consumers
   ────────────────►│                  │◄──────────────────
                    │ ┌──┐ ┌──┐ ┌──┐  │
   Order Processor  │ │M1│ │M2│ │M3│  │  SQS Processor
   Lambda           │ └──┘ └──┘ └──┘  │  Lambda
                    │                  │
                    │ FIFO or Standard │
                    └──────────────────┘

Features:
├── Reliable message queuing
├── Pull-based processing
├── At-least-once delivery
├── Message retention: up to 14 days
├── Automatic scaling
└── Dead-letter queue support

Message Flow:
1. Producer sends message → Queue
2. Message stored reliably
3. Consumer polls queue
4. Consumer processes message
5. Consumer deletes message
```

---

## PaaS vs Serverless Comparison Visual

```
┌──────────────────────────────────────────────────────────────┐
│                    Responsibility Model                       │
└──────────────────────────────────────────────────────────────┘

PaaS Hybrid                         Serverless/FaaS
(Elastic Beanstalk)                 (Lambda)
                                        
┌──────────────────┐                   ┌──────────────────┐
│  Application     │ ← YOU MANAGE      │  Application     │ ← YOU
├──────────────────┤                   │  (Functions)     │
│  Configuration   │ ← YOU MANAGE      ├──────────────────┤
├──────────────────┤                   │                  │
│  Platform        │ ← AWS MANAGES     │                  │
├──────────────────┤                   │                  │
│  Runtime         │ ← AWS MANAGES     │  Runtime         │ ← AWS
├──────────────────┤                   ├──────────────────┤
│  OS              │ ← AWS MANAGES     │  OS              │ ← AWS
├──────────────────┤                   ├──────────────────┤
│  Servers         │ ← AWS MANAGES     │  Servers         │ ← AWS
├──────────────────┤                   ├──────────────────┤
│  Infrastructure  │ ← AWS MANAGES     │  Infrastructure  │ ← AWS
└──────────────────┘                   └──────────────────┘

App runs continuously                 Functions run on-demand
Idle cost (always-on)                 No idle cost (pay per execution)
More control over platform            Less control, more convenience

---

## Cost Comparison Chart

```
Monthly Cost Estimate (Typical Usage)

Elastic Beanstalk (PaaS)           Lambda (Serverless/FaaS)
────────────────────────           ────────────────────────
Running 24/7                       Event-driven execution

┌──────────────────┐               ┌──────────────────┐
│   t3.micro       │               │  1M requests/mo  │
│   ~$7.50/month   │               │  FREE TIER       │
│   (EC2 cost)     │               │  $0.20 after FT  │
│  + S3 storage    │               │                  │
│  Always-on cost  │               │  Pay per use     │
└──────────────────┘               └──────────────────┘
     Moderate                           Very Low
    fixed cost                      variable cost

Best for:                          Best for:
• Web applications                 • Event-driven workloads
• APIs with steady traffic         • Sporadic traffic
• Continuous services              • Microservices
• Moderate control needed          • Auto-scaling needs
```

---

## Event-Driven Architecture Flow

```
┌────────────────────────────────────────────────────────────┐
│              Event-Driven Serverless Pattern               │
└────────────────────────────────────────────────────────────┘

Event Sources                Events              Processors
──────────────              ────────             ──────────

┌─────────────┐             ┌──────┐            ┌──────────┐
│   API       │────────────►│ SNS  │───────────►│ Lambda 1 │
│  Gateway    │             │Topic │            └──────────┘
└─────────────┘             └──────┘                 │
                                                     │
┌─────────────┐             ┌──────┐                ▼
│  S3 Bucket  │────────────►│ SQS  │            ┌──────────┐
│  (Upload)   │             │Queue │───────────►│ Lambda 2 │
└─────────────┘             └──────┘            └──────────┘
                                                     │
┌─────────────┐             ┌──────┐                ▼
│   Scheduler │────────────►│Direct│            ┌──────────┐
│  (Cron)     │             │Invoke│───────────►│ Lambda 3 │
└─────────────┘             └──────┘            └──────────┘

Characteristics:
✓ Loosely coupled components
✓ Asynchronous processing
✓ Automatic scaling
✓ Fault tolerant
✓ Cost effective
```

---

## Demo Deployment Sequence

### Part 1: Elastic Beanstalk Deployment Steps
```
1. deploy-beanstalk.sh execution
   │
   ├─► Step 1: Check AWS CLI & credentials
   │
   ├─► Step 2: Create private S3 bucket
   │           ├─► BlockPublicAccess enabled
   │           └─► Unique name with timestamp
   │
   ├─► Step 3: Package Flask application
   │           ├─► app.py
   │           ├─► requirements.txt
   │           ├─► templates/index.html
   │           └─► .ebextensions/python.config
   │
   ├─► Step 4: Initialize Elastic Beanstalk
   │           ├─► Python 3.9 platform
   │           └─► us-east-1 region
   │
   ├─► Step 5: Create EB environment
   │           ├─► t3.micro instance
   │           ├─► IAM instance profile
   │           ├─► Environment variables (S3 bucket)
   │           └─► Single instance deployment
   │
   └─► Step 6: Display application URL
                │
                └─► EB provisions:
                    ├─► EC2 instance
                    ├─► Security groups
                    ├─► Nginx configuration
                    ├─► Application deployment
                    └─► Health monitoring

Time: ~5-7 minutes total
```

### Part 2: Lambda Deployment Steps
```
2. deploy-lambda.sh execution
   │
   ├─► Step 1: Check AWS CLI
   │
   ├─► Step 2: Create IAM Role
   │           ├─► Trust policy for Lambda
   │           └─► Attach policies (SNS, SQS, Logs)
   │
   ├─► Step 3: Create SNS Topic
   │
   ├─► Step 4: Create SQS Queue
   │
   ├─► Step 5: Package Lambda Functions
   │           ├─► zip sns_handler.py
   │           ├─► zip sqs_processor.py
   │           └─► zip order_processor.py
   │
   ├─► Step 6: Deploy Lambda Functions
   │           ├─► Upload zip files
   │           ├─► Set environment variables
   │           └─► Configure timeouts
   │
   └─► Step 7: Configure Triggers
               ├─► Subscribe SNS → Lambda
               └─► Connect SQS → Lambda

Time: ~2 minutes total
```

---

## Monitoring & Observability

```
┌────────────────────────────────────────────────────────────┐
│                 AWS CloudWatch Integration                  │
└────────────────────────────────────────────────────────────┘

Elastic Beanstalk Metrics            Lambda Metrics
─────────────────────────           ────────────────
• Environment Health                • Invocations
• Instance Health                   • Duration
• Application Requests              • Errors
• HTTP 4xx/5xx errors               • Throttles
• Latency                           • Concurrent Executions

S3 Metrics
──────────
• Bucket Size
• Number of Objects
• Upload/Download Requests

         │                                   │
         └───────────┬───────────────────────┘
                     ▼
         ┌────────────────────┐
         │  CloudWatch Logs   │
         │  - Application logs│
         │  - Error tracking  │
         │  - Performance data│
         └────────────────────┘
                     │
                     ▼
         ┌────────────────────┐
         │  CloudWatch        │
         │  Dashboards        │
         │  - Visual metrics  │
         │  - Custom graphs   │
         └────────────────────┘
```

---

## Security Model

```
┌────────────────────────────────────────────────────────────┐
│                      Security Layers                        │
└────────────────────────────────────────────────────────────┘

1. IAM (Identity & Access Management)
   ├─► Users & Roles
   ├─► Policies & Permissions
   └─► Access Keys

2. Security Groups (EC2)
   ├─► Inbound Rules (Port 5000, 22)
   ├─► Outbound Rules (All allowed)
   └─► Stateful firewall

3. Execution Roles (Lambda)
   ├─► Lambda can access SNS
   ├─► Lambda can access SQS
   └─► Lambda can write logs

4. Network Security
   ├─► VPC (Virtual Private Cloud)
   ├─► Public/Private Subnets
   └─► Internet Gateway

5. Encryption
   ├─► At rest (EBS, S3)
   ├─► In transit (TLS/SSL)
   └─► KMS key management
```

---

## Scaling Patterns

### Elastic Beanstalk Scaling (Configurable)
```
Traffic:  Low ────► Medium ────► High ────► Low
          │         │            │          │
EB:       │         │            │          │
┌─────┐   │  ┌─────┬─────┐      │  ┌──┬──┬──┬──┐  │  ┌─────┐
│ i-1 │◄──┘  │ i-1 │ i-2 │◄─────┘  │i1│i2│i3│i4│◄─┘  │ i-1 │
└─────┘      └─────┴─────┘         └──┴──┴──┴──┘     └─────┘
  (1)           (2)                    (4)              (1)

Auto-scaling available (disabled for demo)
Can configure min/max instances
```

### Lambda Scaling (Automatic/Instant)
```
Requests: Low ────► High ────► Very High ────► Low
          │         │          │               │
Lambda:   │         │          │               │
 ┌─┐◄─────┘   ┌─┬─┬─┬─┐◄─────┘ ┌─┬─┬─┬─┬─┬─┬─┬─┐◄─┘   ┌─┐
 │1│         │1│2│3│4│        │1│2│3│4│5│6│7│8│9│    │1│
 └─┘         └─┴─┴─┴─┘        └─┴─┴─┴─┴─┴─┴─┴─┴─┘    └─┘
 (1)           (4)              (100s-1000s)           (1)

Automatic scaling, no configuration needed
```

---

## Use this document for:
- Understanding architecture before demo
- Creating PowerPoint slides
- Explaining concepts to audience
- Quick visual reference during presentation
- Drawing on whiteboard if needed

**Print relevant diagrams for easy reference during your presentation!**

# AWS Cloud Computing Demo - Complete Guide

## 🎯 Overview

This repository contains a comprehensive 20-minute demonstration of AWS cloud computing fundamentals, focusing on:
- **PaaS Hybrid**: Elastic Beanstalk managed platform with S3 integration
- **Serverless/FaaS**: Event-driven architecture with Lambda, SNS, and SQS
- **Comparison**: Understanding when to use managed platforms vs serverless

Perfect for presentations, workshops, and educational purposes.

---

## 📋 What's Included

### Part 1: Elastic Beanstalk Web Application (PaaS Hybrid)
- Flask web application with file upload
- S3 buckets are private (IAM role access only)
- Automated Elastic Beanstalk deployment
- Integrated monitoring and auto-scaling

### Part 2: Serverless Architecture (Serverless/FaaS)
- Three Lambda functions demonstrating event-driven architecture
- SNS (Simple Notification Service) integration
- SQS (Simple Queue Service) processing
- Complete serverless workflow

### Documentation
- **PRESENTATION_SCRIPT.md** - Detailed 20-minute presentation script with timing
- **ARCHITECTURE_DIAGRAMS.md** - Visual architecture diagrams and comparisons
- **Part 1 README.md** - Elastic Beanstalk deployment guide
- **Part 2 README.md** - Serverless architecture guide

---

## 🚀 Quick Start

### Prerequisites
- AWS Account with appropriate permissions
- AWS CLI installed and configured
- macOS/Linux environment (or WSL on Windows)
- Python 3.9+ installed
- (Optional) `aws-azure-login` for federated authentication

### Authentication Setup (For Federated/Azure AD Users)

If your AWS account uses **Azure AD authentication** (common in enterprise environments), you can use `aws-azure-login`:

#### Install aws-azure-login
```bash
# Install Node.js if you don't have it
brew install node

# Install aws-azure-login
npm install -g aws-azure-login
```

#### Configure aws-azure-login
```bash
aws-azure-login --configure
```

Follow the prompts to set up your Azure AD integration.

#### Login Before Running Demo
```bash
aws-azure-login -m gui --no-sandbox
```

This will open a browser window for Azure AD authentication. Complete the login, then verify:

```bash
aws sts get-caller-identity
```

You should see your AWS account information. You're now ready to run the demo!

---

### 1. Verify Setup
```bash
# Run verification script
chmod +x verify-setup.sh
./verify-setup.sh
```

### 2. Run Part 1 - Elastic Beanstalk Demo (IaaS/PaaS)
```bash
cd part1-ec2-demo
chmod +x deploy-beanstalk.sh
./deploy-beanstalk.sh

# Wait 5-7 minutes for deployment
# Access at: URL provided in script output
```

### 3. Run Part 2 - Serverless Demo (PaaS)
```bash
cd ../part2-serverless-demo
chmod +x deploy-lambda.sh
./deploy-lambda.sh

# Test the functions
chmod +x test-lambda.sh
./test-lambda.sh
```

### 4. Clean Up (Important!)
```bash
cd ..
chmod +x cleanup.sh
./cleanup.sh
```

---

## 📁 Repository Structure

```
module4_demo/
├── README.md                           # This file
├── PRESENTATION_SCRIPT.md              # Detailed 20-min presentation script
├── ARCHITECTURE_DIAGRAMS.md            # Visual architecture diagrams
├── INFOSEC_ALERT_EXPLAINED.md          # Security compliance information
├── GETTING_STARTED.md                  # Quick start guide
├── verify-setup.sh                     # Pre-flight verification script
│
├── part1-ec2-demo/                     # PaaS Hybrid Demo
│   ├── README.md                       # Elastic Beanstalk demo documentation
│   ├── app.py                          # Flask web application with S3
│   ├── requirements.txt                # Python dependencies
│   ├── templates/
│   │   └── index.html                  # Web interface
│   ├── .ebextensions/                  # Elastic Beanstalk configuration
│   ├── deploy-beanstalk.sh             # Automated deployment
│   └── cleanup-beanstalk.sh            # Cleanup script
│
└── part2-serverless-demo/              # Serverless/FaaS Demo
    ├── README.md                       # Serverless demo documentation
    ├── lambda-functions/
    │   ├── sns_handler.py              # SNS-triggered Lambda
    │   ├── sqs_processor.py            # SQS-triggered Lambda
    │   └── order_processor.py          # Order processing Lambda
    ├── deploy-lambda.sh                # Automated deployment
    ├── test-lambda.sh                  # Test all functions
    └── cleanup-lambda.sh               # Lambda cleanup
```

---

## 🎓 Learning Objectives

After this demo, participants will understand:

1. **PaaS Hybrid Concepts (Elastic Beanstalk)**
   - Managed platform deployment
   - Automatic scaling and load balancing
   - Integrated monitoring and health checks
   - Platform-managed infrastructure

2. **Serverless/FaaS Concepts (Lambda)**
   - Event-driven architecture
   - Message queuing patterns (SNS/SQS)
   - Pay-per-execution model
   - Automatic scaling to zero

3. **Service Model Comparison**
   - When to use PaaS Hybrid vs Serverless
   - Cost models (instance-based vs per-execution)
   - Management overhead differences
   - Scalability considerations

---

## 📊 Demo Timing (20 Minutes)

| Section | Duration | Description |
|---------|----------|-------------|
| Introduction | 1 min | Overview of cloud service models |
| Part 1: EB Setup | 5 min | Deploy Flask app to Elastic Beanstalk |
| Part 1: Demo | 3 min | Show running application with S3 |
| Part 1: Discussion | 2 min | IaaS/PaaS key points |
| Part 2: Lambda Setup | 2 min | Deploy serverless architecture |
| Part 2: Demo | 3 min | Trigger Lambda functions |
| Part 2: Discussion | 3 min | PaaS benefits |
| Comparison | 2 min | IaaS vs PaaS table |
| Q&A | 1 min | Questions and wrap-up |

---

## 💰 Cost Information

### Expected Demo Costs
- **Elastic Beanstalk**: Free (platform itself)
- **EC2 t3.micro**: $0.0104/hour (Free Tier eligible)
- **S3 Storage**: < $0.01 for demo files
- **Lambda**: $0.00 (within Free Tier)
- **SNS**: $0.00 (first 1000 publishes free)
- **SQS**: $0.00 (first 1M requests free)

**Total Demo Cost**: < $0.10 if cleaned up within an hour

### AWS Free Tier
- Elastic Beanstalk: Free (no additional charge)
- EC2: 750 hours/month (t2.micro or t3.micro)
- S3: 5GB storage, 20,000 GET requests, 2,000 PUT requests
- Lambda: 1M requests/month
- SNS: 1,000 publishes/month
- SQS: 1M requests/month

⚠️ **Always run cleanup script after demo to avoid charges!**

---

## 🔧 Detailed Setup Instructions

### 1. Install AWS CLI

**macOS:**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Verify:**
```bash
aws --version
```

### 2. Configure AWS Credentials

```bash
aws configure
```

Enter:
- **AWS Access Key ID**: [Your access key]
- **AWS Secret Access Key**: [Your secret key]
- **Default region**: `us-east-1`
- **Default output format**: `json`

### 3. Verify Setup

```bash
./verify-setup.sh
```

---

## 🎤 Presentation Guide

### Before Your Presentation

1. **Read the full guide**: Review `PRESENTATION_SCRIPT.md`
2. **Test everything**: Run through both demos completely
3. **Prepare environment**: 
   - Large terminal font (16-18pt)
   - Clean browser with AWS Console bookmarks
   - Have CloudWatch Logs open in a tab
4. **Clean up**: Run cleanup scripts before demo

### During Your Presentation

1. **Follow the script**: Use `PRESENTATION_SCRIPT.md` for timing
2. **Have logs ready**: Keep CloudWatch Logs tab open
3. **Show, don't just tell**: Live demos are more impactful
4. **Engage audience**: Ask questions, take brief pauses

### After Your Presentation

1. **Run cleanup**: `./cleanup.sh`
2. **Verify deletion**: Check AWS Console
3. **Share resources**: Provide GitHub link to participants

---

## 🐛 Troubleshooting

### Elastic Beanstalk Application Not Loading

```bash
# Check environment status
eb status

# View environment logs
eb logs

# SSH into EB instance (if needed)
eb ssh
```

### S3 Upload Issues

Check IAM role permissions for Elastic Beanstalk instances:
- AmazonS3FullAccess policy should be attached
- Verify bucket name in environment variables

### Lambda Not Triggering

```bash
# View logs
aws logs tail /aws/lambda/demo-sns-handler --follow

# Test direct invocation
aws lambda invoke \
    --function-name demo-sns-handler \
    --payload '{"test":"message"}' \
    response.json
```

### Permission Errors

- Verify IAM user has required policies
- Wait 10 seconds after creating IAM roles
- Check CloudWatch Logs for detailed errors

---

## 📚 Additional Resources

### AWS Documentation
- [Elastic Beanstalk Developer Guide](https://docs.aws.amazon.com/elasticbeanstalk/)
- [S3 User Guide](https://docs.aws.amazon.com/s3/)
- [Lambda Developer Guide](https://docs.aws.amazon.com/lambda/)
- [SNS Documentation](https://docs.aws.amazon.com/sns/)
- [SQS Documentation](https://docs.aws.amazon.com/sqs/)

### Learning Resources
- [AWS Free Tier](https://aws.amazon.com/free)
- [AWS Training](https://aws.amazon.com/training)
- [AWS Certified Cloud Practitioner](https://aws.amazon.com/certification/certified-cloud-practitioner/)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## ⚠️ Important Notes

1. **Clean up resources**: Always run `./cleanup.sh` after demos
2. **Monitor costs**: Set up billing alerts in AWS Console
3. **Free Tier limits**: Monitor usage to stay within free tier
4. **Security**: Never commit AWS credentials to Git
5. **Regional resources**: Demo uses us-east-1; adjust if needed

---

## 🎯 Key Takeaways

### PaaS Hybrid (Elastic Beanstalk + S3)
✅ Managed platform - AWS handles infrastructure  
✅ Automatic scaling and load balancing  
✅ Integrated monitoring and health checks  
✅ Easy deployment and updates  
❌ Instance-based pricing (always running)  
❌ Platform-specific limitations  

### Serverless/FaaS (Lambda, SNS, SQS)
✅ No server management  
✅ Automatic scaling (including to zero)  
✅ Pay per execution only  
❌ Cold start latency  
❌ Execution time limits  

---

**Ready to start? Run `./verify-setup.sh` and begin your cloud computing journey! ☁️**

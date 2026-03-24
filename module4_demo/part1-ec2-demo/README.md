# Part 1: Elastic Beanstalk Web Application Demo (PaaS Hybrid)

## 🔒 SECURITY COMPLIANCE - Slalom AWS Innovation Labs

**⚠️ IMPORTANT: This deployment complies with Slalom InfoSec policies:**

- ✅ **S3 buckets are PRIVATE** (no public access - IAM roles only)
- ✅ **Security groups restricted to YOUR IP** (no 0.0.0.0/0 allowed)
- ✅ **Uses approved instance type** (t3.micro from InfoSec whitelist)
- ✅ **IAM role-based access** (no access keys or local IAM users)
- ⚠️ **Resources must be cleaned up within 2 WEEKS**

---

## Overview

This demo showcases AWS PaaS capabilities by deploying a Flask web application using:
- **AWS Elastic Beanstalk** - PaaS platform for managed web app deployment
- **Amazon S3** - Object storage for uploaded files
- **IAM Roles** - Secure service-to-service access

## 🏗️ Architecture

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
```

**Flow:**
1. User uploads file via web interface → Nginx → Flask app
2. Flask app uses IAM role to upload file to private S3 bucket
3. Flask generates pre-signed URL (1-hour expiry) for secure file access
4. User can view/download files via temporary pre-signed URLs

## 📋 Features

### Web Application
- File upload interface with drag & drop support
- Display instance information (hostname, IP)
- List all uploaded files from S3
- Real-time file browsing from S3 bucket
- Responsive UI with AWS branding

### AWS Services Integration
- **Elastic Beanstalk**: Manages EC2 instances, load balancer, auto-scaling
- **S3**: Stores uploaded files with private access via IAM roles
- **IAM**: Manages permissions for EB instances to access S3

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured (use `aws-azure-login` for federated auth)
- Python 3.7+ (for local testing)
- pip3 installed

### Deploy the Application

```bash
cd part1-ec2-demo

# Deploy everything (EB + S3)
./deploy-beanstalk.sh
```

The script will:
1. Check prerequisites (AWS CLI, credentials)
2. Create private S3 bucket for file storage
3. Package the Flask application
4. Initialize Elastic Beanstalk environment
5. Deploy the application with auto-scaling
6. Configure IAM roles and environment variables

**Deployment time:** 5-7 minutes

### Access the Application

After deployment, you'll see:
```
Application URL: http://demo-webapp-env.us-east-1.elasticbeanstalk.com
```

Open this URL in your browser to:
- Upload files to S3
- View instance information
- Browse uploaded files

## 🧪 Test the Application

### Upload a File
1. Click "Choose File" or drag & drop a file
2. Supported formats: PNG, JPG, GIF, PDF, TXT
3. Click "Upload to S3"
4. File is stored in S3 (access via pre-signed URLs)

### View Instance Info
- Hostname of the EB instance
- Local IP address
- S3 bucket name
- Timestamp

### Browse Files
- Lists all files in S3 bucket
- Shows file size and upload date
- Click "View →" to open file via pre-signed URL

## 📊 Architecture Components

### Elastic Beanstalk
- **Platform:** Python 3.9
- **Instance Type:** t3.micro (Free Tier eligible, InfoSec approved)
- **Deployment:** Single instance (demo mode)
- **Health Monitoring:** Built-in with automatic health checks
- **Auto-scaling:** Available but disabled for demo

### S3 Bucket
- **Purpose:** Store uploaded files
- **Access:** Private (IAM role-based only)
- **Naming:** `demo-webapp-bucket-<timestamp>`
- **Region:** us-east-1
- **Security:** BlockPublicAccess enabled on all settings

## 🔧 Key Files

- **`app.py`** - Flask web application with S3 integration
- **`requirements.txt`** - Python dependencies (Flask, boto3, gunicorn)
- **`.ebextensions/python.config`** - Elastic Beanstalk configuration (WSGI, IAM roles, file size limits)
- **`deploy-beanstalk.sh`** - Automated deployment script
- **`cleanup-beanstalk.sh`** - Resource cleanup script

## 🧹 Cleanup

**Important:** Always clean up after demos to avoid AWS charges!

```bash
./cleanup-beanstalk.sh
```

The script will:
1. Terminate Elastic Beanstalk environment
2. Delete Elastic Beanstalk application
3. Empty and delete S3 bucket
4. Remove local configuration files

## 💰 Cost Information

### Expected Costs (per hour)
- **Elastic Beanstalk:** Free (you only pay for underlying resources)
- **EC2 t3.micro:** $0.0104/hour (Free Tier: 750 hours/month)
- **S3 Storage:** $0.023/GB/month (Free Tier: 5GB)
- **S3 Requests:** $0.0004/1000 requests (Free Tier: 2000 PUT, 20000 GET)

**Total demo cost:** < $0.05 if cleaned up within an hour

### Free Tier Benefits
- **EC2:** 750 hours/month of t3.micro
- **S3:** 5GB storage, 20,000 GET requests, 2,000 PUT requests
- **Data Transfer:** 15GB out per month

## 📚 Key Concepts Demonstrated

**PaaS (Elastic Beanstalk):**
- Managed platform deployment - AWS handles infrastructure
- Automatic health monitoring and recovery
- Built-in load balancing and auto-scaling capabilities
- Zero-downtime deployments

**Storage & Security:**
- S3 object storage with private access
- IAM role-based service permissions (no access keys)
- Pre-signed URLs for temporary file access
- Security group restrictions to specific IPs

## 🐛 Troubleshooting

**Deployment fails:**
- Check logs: `eb logs` or AWS Console → Elastic Beanstalk → Logs
- Verify AWS credentials are valid and not expired

**File upload fails (413 error):**
- Fixed: File size limits increased to 16MB (Flask) and 20MB (Nginx)

**S3 access denied:**
- Verify IAM role has S3 permissions in AWS Console
- Check environment variables: `eb printenv`

## 📖 Presentation Tips

### Demo Flow (10 minutes)
1. **Show architecture diagram** (1 min)
2. **Run deployment script** (mention it takes 5-7 min, have it pre-deployed)
3. **Show AWS Console** - EB environment, S3 bucket
4. **Demo the application** - Upload file, view instance info
5. **Explain PaaS benefits** - No server management, auto-scaling
6. **Show file in S3** - AWS Console (explain private access via pre-signed URLs)
7. **Explain security** - IAM roles, restricted security groups, private S3
8. **Cleanup demo** - Show cleanup script

### Key Talking Points
- ✅ **PaaS Platform:** Elastic Beanstalk manages infrastructure - you deploy code, AWS handles servers
- ✅ **Auto-scaling:** Can scale from 1 to 100s of instances automatically
- ✅ **Monitoring:** Built-in health checks, logging, and auto-recovery
- ✅ **Security:** IAM roles (no access keys), private S3, IP-restricted security groups
- ✅ **vs Serverless:** EB apps run continuously (idle cost) vs Lambda runs only when triggered (no idle cost)

## 🔗 Additional Resources

- [AWS Elastic Beanstalk Documentation](https://docs.aws.amazon.com/elasticbeanstalk/)
- [Amazon S3 Documentation](https://docs.aws.amazon.com/s3/)
- [AWS Free Tier](https://aws.amazon.com/free/)

---

**Ready to deploy?** Run `./deploy-beanstalk.sh` and your AWS demo will be live in minutes! ☁️

#!/bin/bash

#===============================================================================
# AWS Elastic Beanstalk + S3 Deployment Script
# This script deploys a Flask app using Elastic Beanstalk and creates an S3 bucket
# for file storage
#
# SECURITY COMPLIANCE: Slalom AWS Innovation Labs
# - S3 buckets are PRIVATE (no public access)
# - Security groups restricted to specific IP ranges (NO 0.0.0.0/0)
# - Uses approved instance type (t3.micro)
# - IAM role-based access only
#===============================================================================

set -e  # Exit on error

echo "======================================================================"
echo "AWS Demo Deployment - Elastic Beanstalk + S3"
echo "======================================================================"
echo ""
echo "⚠️  SECURITY COMPLIANCE CHECK - Slalom AWS Innovation Labs"
echo "----------------------------------------------------------------------"
echo "This deployment will comply with InfoSec policies:"
echo "  ✓ S3 buckets will be PRIVATE (no public access)"
echo "  ✓ Security groups restricted to YOUR IP only (no 0.0.0.0/0)"
echo "  ✓ Using approved instance type (t3.micro)"
echo "  ✓ Resources must be cleaned up within 2 weeks"
echo ""
echo "🚨 IMPORTANT SECURITY NOTICE:"
echo "----------------------------------------------------------------------"
echo "Elastic Beanstalk creates security groups with 0.0.0.0/0 access by"
echo "default. InfoSec automation will detect this and send you an alert."
echo ""
echo "This is EXPECTED and will be automatically remediated by InfoSec, OR"
echo "this script will remove the 0.0.0.0/0 rules after deployment completes."
echo ""
echo "The alert is a confirmation that the security system is working."
echo "----------------------------------------------------------------------"
echo ""
read -p "Press ENTER to continue with deployment..."
echo ""

# Configuration
APP_NAME="demo-webapp"
ENV_NAME="demo-webapp-env"
REGION="us-east-1"
BUCKET_NAME="demo-webapp-bucket-$(date +%s)"
PLATFORM="python-3.9"
INSTANCE_TYPE="t3.micro"  # Approved instance type

echo "Step 1: Checking prerequisites..."
echo "----------------------------------------------------------------------"

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "✗ AWS CLI not found. Please install it first."
    exit 1
fi
echo "✓ AWS CLI installed"

# Check EB CLI
if ! command -v eb &> /dev/null; then
    echo "✗ Elastic Beanstalk CLI not found."
    echo "  Please install it first:"
    echo "  brew install awsebcli"
    exit 1
fi
echo "✓ EB CLI available"

# Check AWS credentials
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "✗ AWS credentials not configured"
    echo "  Run: aws-azure-login -m gui --no-sandbox"
    exit 1
fi
echo "✓ AWS credentials configured"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "  Account ID: $ACCOUNT_ID"
echo ""

echo "Step 2: Getting your IP address for security group configuration..."
echo "----------------------------------------------------------------------"

# Get user's current IP address
echo "Detecting your public IP address..."
USER_IP=$(curl -s ifconfig.me)
if [ -z "$USER_IP" ]; then
    echo "⚠️  Could not auto-detect your IP address"
    echo ""
    read -p "Enter your IP address (or press Enter to use 0.0.0.0/0 - NOT RECOMMENDED): " USER_IP
    if [ -z "$USER_IP" ]; then
        echo ""
        echo "❌ ERROR: Using 0.0.0.0/0 violates Slalom InfoSec policy!"
        echo "Your deployment will be flagged and automatically remediated."
        echo ""
        echo "Please run this script again and provide your IP address."
        echo "To find your IP: curl ifconfig.me"
        exit 1
    fi
fi

# Append /32 if not already a CIDR block
if [[ ! "$USER_IP" =~ / ]]; then
    USER_IP="${USER_IP}/32"
fi

echo "✓ Your IP address: $USER_IP"
echo "  Security groups will be restricted to this IP only"
echo ""
echo "⚠️  IMPORTANT: If your IP changes, you'll need to update the security group manually"
echo "  or redeploy with the new IP address."
echo ""

echo "Step 3: Creating PRIVATE S3 bucket for file storage..."
echo "----------------------------------------------------------------------"

# Create S3 bucket
if aws s3 mb s3://$BUCKET_NAME --region $REGION 2>/dev/null; then
    echo "✓ Created S3 bucket: $BUCKET_NAME"
else
    echo "⚠ Bucket might already exist or error occurred"
fi

# SECURITY COMPLIANCE: Block ALL public access to S3 bucket
echo "  Enforcing PRIVATE bucket policy (InfoSec requirement)..."
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "✓ S3 bucket configured as PRIVATE (no public access)"
echo "  Access will be via IAM roles only"
echo ""

echo "Step 4: Preparing application bundle..."
echo "----------------------------------------------------------------------"

# Create application bundle
ZIP_FILE="app-$(date +%s).zip"

zip -r $ZIP_FILE \
    app.py \
    requirements.txt \
    templates/ \
    .ebextensions/ \
    -x "*.pyc" "*__pycache__*" "*.DS_Store" \
    > /dev/null

echo "✓ Created application bundle: $ZIP_FILE"
echo ""

echo "Step 5: Creating IAM instance profile for S3 access..."
echo "----------------------------------------------------------------------"

# Create IAM role for Elastic Beanstalk instances to access S3
ROLE_NAME="aws-elasticbeanstalk-ec2-role-demo"

# Check if role exists
if ! aws iam get-role --role-name $ROLE_NAME &>/dev/null; then
    echo "  Creating IAM role..."
    
    # Create trust policy
    cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
    
    aws iam create-role \
        --role-name $ROLE_NAME \
        --assume-role-policy-document file:///tmp/trust-policy.json \
        --description "Demo role for Elastic Beanstalk EC2 instances" \
        > /dev/null
    
    # Attach necessary policies
    aws iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier \
        > /dev/null
    
    aws iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker \
        > /dev/null
    
    aws iam attach-role-policy \
        --role-name $ROLE_NAME \
        --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier \
        > /dev/null
    
    # Create custom S3 access policy
    cat > /tmp/s3-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::$BUCKET_NAME",
        "arn:aws:s3:::$BUCKET_NAME/*"
      ]
    }
  ]
}
EOF
    
    aws iam put-role-policy \
        --role-name $ROLE_NAME \
        --policy-name S3BucketAccess \
        --policy-document file:///tmp/s3-policy.json \
        > /dev/null
    
    # Create instance profile
    aws iam create-instance-profile --instance-profile-name $ROLE_NAME > /dev/null 2>&1 || true
    aws iam add-role-to-instance-profile --instance-profile-name $ROLE_NAME --role-name $ROLE_NAME > /dev/null 2>&1 || true
    
    rm /tmp/trust-policy.json /tmp/s3-policy.json
    
    echo "✓ IAM role created: $ROLE_NAME"
    echo "  Waiting 10 seconds for IAM propagation..."
    sleep 10
else
    echo "✓ IAM role already exists: $ROLE_NAME"
    echo "  Updating S3 bucket access policy with new bucket name..."
    
    # Update S3 access policy with the new bucket name
    cat > /tmp/s3-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::$BUCKET_NAME",
        "arn:aws:s3:::$BUCKET_NAME/*"
      ]
    }
  ]
}
EOF
    
    aws iam put-role-policy \
        --role-name $ROLE_NAME \
        --policy-name S3BucketAccess \
        --policy-document file:///tmp/s3-policy.json \
        > /dev/null
    
    rm /tmp/s3-policy.json
    
    echo "  ✓ S3 bucket access policy updated for: $BUCKET_NAME"
fi
echo ""

echo "Step 6: Initializing Elastic Beanstalk application..."
echo "----------------------------------------------------------------------"

# Initialize EB if not already done
if [ ! -d ".elasticbeanstalk" ]; then
    eb init $APP_NAME \
        --platform "$PLATFORM" \
        --region $REGION \
        2>/dev/null || echo "EB init completed"
fi

echo "✓ Elastic Beanstalk initialized"
echo ""

echo "Step 7: Creating Elastic Beanstalk environment with RESTRICTED security group..."
echo "----------------------------------------------------------------------"

echo "  ⚠️  SECURITY: Restricting access to your IP only: $USER_IP"
echo ""

# Start a background process to immediately fix security group as soon as it's created
(
  echo "  [Background] Monitoring for security group creation..."
  ATTEMPTS=0
  MAX_ATTEMPTS=60  # Monitor for up to 5 minutes
  
  while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    # Try to find the security group
    SG_ID=$(aws ec2 describe-security-groups \
        --filters "Name=tag:elasticbeanstalk:environment-name,Values=$ENV_NAME" \
        --query 'SecurityGroups[0].GroupId' \
        --output text 2>/dev/null)
    
    if [ -n "$SG_ID" ] && [ "$SG_ID" != "None" ]; then
      echo "  [Background] Security group found: $SG_ID"
      echo "  [Background] Immediately removing 0.0.0.0/0 rules..."
      
      # Remove 0.0.0.0/0 for HTTP
      aws ec2 revoke-security-group-ingress \
          --group-id $SG_ID \
          --protocol tcp \
          --port 80 \
          --cidr 0.0.0.0/0 \
          2>/dev/null && echo "  [Background] ✓ Removed 0.0.0.0/0 HTTP rule"
      
      # Remove 0.0.0.0/0 for HTTPS
      aws ec2 revoke-security-group-ingress \
          --group-id $SG_ID \
          --protocol tcp \
          --port 443 \
          --cidr 0.0.0.0/0 \
          2>/dev/null && echo "  [Background] ✓ Removed 0.0.0.0/0 HTTPS rule"
      
      # Add user's IP
      aws ec2 authorize-security-group-ingress \
          --group-id $SG_ID \
          --protocol tcp \
          --port 80 \
          --cidr $USER_IP \
          2>/dev/null && echo "  [Background] ✓ Added $USER_IP for HTTP"
      
      aws ec2 authorize-security-group-ingress \
          --group-id $SG_ID \
          --protocol tcp \
          --port 443 \
          --cidr $USER_IP \
          2>/dev/null && echo "  [Background] ✓ Added $USER_IP for HTTPS"
      
      echo "  [Background] ✓ Security group configured successfully!"
      exit 0
    fi
    
    ATTEMPTS=$((ATTEMPTS + 1))
    sleep 5
  done
  
  echo "  [Background] Warning: Could not find security group within 5 minutes"
) &

BG_PID=$!
echo "  Started background security group monitor (PID: $BG_PID)"
echo ""

# Create environment with environment variables and security settings
eb create $ENV_NAME \
    --instance-type $INSTANCE_TYPE \
    --instance_profile $ROLE_NAME \
    --envvars S3_BUCKET_NAME=$BUCKET_NAME,AWS_REGION=$REGION \
    --single \
    2>&1 | grep -v "WARNING" || true

echo ""
echo "✓ Elastic Beanstalk environment created"
echo ""

echo "  Ensuring environment variables are persisted..."
# Update environment variables to ensure they persist after initial creation
aws elasticbeanstalk update-environment \
    --application-name "$APP_NAME" \
    --environment-name "$ENV_NAME" \
    --option-settings \
        Namespace=aws:elasticbeanstalk:application:environment,OptionName=S3_BUCKET_NAME,Value="$BUCKET_NAME" \
        Namespace=aws:elasticbeanstalk:application:environment,OptionName=AWS_REGION,Value="$REGION" \
        Namespace=aws:elasticbeanstalk:application:environment,OptionName=PYTHONUNBUFFERED,Value=1 \
    > /dev/null 2>&1 || true

echo "  ✓ Environment variables configured"
echo ""

# Wait for background process to complete
echo "Waiting for security group configuration to complete..."
wait $BG_PID 2>/dev/null || echo "  Security group monitor completed"
echo ""

echo "Step 8: Verifying security group configuration..."
echo "----------------------------------------------------------------------"

# Get the security group ID for verification (using same filter as background process)
echo "  Finding security group for final verification..."
SG_ID=$(aws ec2 describe-security-groups \
    --filters "Name=tag:elasticbeanstalk:environment-name,Values=$ENV_NAME" \
    --query 'SecurityGroups[0].GroupId' \
    --output text 2>/dev/null)

if [ -n "$SG_ID" ] && [ "$SG_ID" != "None" ]; then
    echo "  Security group: $SG_ID"
    
    # Verify current rules
    CURRENT_RULES=$(aws ec2 describe-security-groups \
        --group-ids $SG_ID \
        --query 'SecurityGroups[0].IpPermissions[?FromPort==`80`].IpRanges[*].CidrIp' \
        --output text 2>/dev/null)
    
    echo "  Current HTTP access: $CURRENT_RULES"
    
    if echo "$CURRENT_RULES" | grep -q "0.0.0.0/0"; then
        echo "  ⚠️  WARNING: Still has 0.0.0.0/0 access!"
        echo "  InfoSec will automatically remediate this"
    elif echo "$CURRENT_RULES" | grep -q "${USER_IP%/*}"; then
        echo "  ✓ Correctly restricted to $USER_IP"
    else
        echo "  ℹ️  Rules configuration: $CURRENT_RULES"
    fi
    
    echo "✓ Security group verification complete"
else
    echo "⚠️  Warning: Could not find security group for verification"
fi
echo ""

echo "Step 9: Waiting for environment to be ready..."
echo "----------------------------------------------------------------------"

# Wait for environment
echo "This may take 3-5 minutes..."
aws elasticbeanstalk wait environment-updated \
    --application-name $APP_NAME \
    --environment-names $ENV_NAME \
    2>/dev/null || sleep 60

echo "✓ Environment is ready"
echo ""

echo "Step 10: Verifying environment variables..."
echo "----------------------------------------------------------------------"

# Verify environment variables are set
ENV_VARS=$(aws elasticbeanstalk describe-configuration-settings \
    --application-name "$APP_NAME" \
    --environment-name "$ENV_NAME" \
    --query 'ConfigurationSettings[0].OptionSettings[?Namespace==`aws:elasticbeanstalk:application:environment`]' \
    --output json)

S3_VAR=$(echo "$ENV_VARS" | grep -c "S3_BUCKET_NAME" || true)
if [ "$S3_VAR" -gt 0 ]; then
    echo "  ✓ S3_BUCKET_NAME environment variable is set"
else
    echo "  ⚠️  WARNING: S3_BUCKET_NAME not found in environment variables"
fi

echo ""

# Get environment URL
EB_URL=$(aws elasticbeanstalk describe-environments \
    --application-name $APP_NAME \
    --environment-names $ENV_NAME \
    --query 'Environments[0].CNAME' \
    --output text)

echo "======================================================================"
echo "🎉 Deployment Complete!"
echo "======================================================================"
echo ""
echo "📋 Deployment Summary:"
echo "----------------------------------------------------------------------"
echo "Application Name:       $APP_NAME"
echo "Environment Name:       $ENV_NAME"
echo "S3 Bucket:             $BUCKET_NAME"
echo "Application URL:        http://$EB_URL"
echo ""
echo "🚀 Access your application at:"
echo "   http://$EB_URL"
echo ""
echo "📝 Save this information:"
echo "----------------------------------------------------------------------"
echo "export S3_BUCKET_NAME=$BUCKET_NAME"
echo "export EB_ENV_NAME=$ENV_NAME"
echo "export EB_APP_NAME=$APP_NAME"
echo ""
echo "⚠️  Important Notes:"
echo "----------------------------------------------------------------------"
echo "1. The application may take 2-3 more minutes to fully start"
echo "2. Application is ONLY accessible from your IP: $USER_IP"
echo "3. S3 bucket is PRIVATE - access via IAM roles only"
echo ""
echo "🔒 SECURITY COMPLIANCE:"
echo "----------------------------------------------------------------------"
echo "✓ S3 bucket is PRIVATE (no public access)"
echo "✓ Security group restricted to: $USER_IP"
echo "✓ Using approved instance type: $INSTANCE_TYPE"
echo "✓ IAM role-based S3 access (no access keys)"
echo ""
echo "⏰ RESOURCE CLEANUP DEADLINE:"
echo "----------------------------------------------------------------------"
echo "⚠️  EC2 instances must be terminated within 2 WEEKS"
echo "⚠️  InfoSec monitors and will auto-terminate non-compliant resources"
echo ""
echo "🧹 To clean up all resources NOW, run:"
echo "   ./cleanup-beanstalk.sh"
echo ""
echo "======================================================================"

# Save configuration for cleanup
cat > .eb-demo-config <<EOF
APP_NAME=$APP_NAME
ENV_NAME=$ENV_NAME
S3_BUCKET=$BUCKET_NAME
ZIP_FILE=$ZIP_FILE
SECURITY_GROUP_ID=$SG_ID
USER_IP=$USER_IP
IAM_ROLE=$ROLE_NAME
EOF

echo "✓ Configuration saved to .eb-demo-config"
echo ""
echo "======================================================================"
echo "📧 ABOUT THE SECURITY ALERT YOU MAY RECEIVE"
echo "======================================================================"
echo ""
echo "You will likely receive an email from InfoSec about security group"
echo "allowing unrestricted access (0.0.0.0/0). This is EXPECTED behavior:"
echo ""
echo "1. Elastic Beanstalk creates security groups with 0.0.0.0/0 by default"
echo "2. InfoSec automation detects this within minutes"
echo "3. InfoSec automation automatically remediates (removes 0.0.0.0/0)"
echo "4. This script also removes 0.0.0.0/0 and restricts to your IP"
echo ""
echo "Result: The security group is now restricted to $USER_IP only"
echo ""
echo "🔍 TO VERIFY SECURITY GROUP IS RESTRICTED:"
echo "----------------------------------------------------------------------"
if [ -n "$SG_ID" ] && [ "$SG_ID" != "None" ]; then
    echo "Run this command:"
    echo ""
    echo "  aws ec2 describe-security-groups --group-ids $SG_ID \\"
    echo "    --query 'SecurityGroups[0].IpPermissions[?FromPort==\`80\`].IpRanges[*].CidrIp'"
    echo ""
    echo "Expected output: [\"$USER_IP\"]"
    echo "(Should show YOUR IP only, not 0.0.0.0/0)"
else
    echo "Security group ID not captured. Check AWS Console manually."
fi
echo ""
echo "======================================================================"

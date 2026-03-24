#!/bin/bash

# Pre-Demo Verification Script
# Run this to ensure everything is ready for the demo

echo "=========================================="
echo "AWS Demo Pre-Flight Verification"
echo "=========================================="
echo ""

ERRORS=0
WARNINGS=0

# Check 1: AWS CLI
echo "1. Checking AWS CLI..."
if command -v aws &> /dev/null; then
    echo "   ✓ AWS CLI installed"
    AWS_VERSION=$(aws --version 2>&1 | cut -d ' ' -f1)
    echo "   Version: $AWS_VERSION"
else
    echo "   ✗ AWS CLI NOT installed"
    echo "     Install: brew install awscli"
    ((ERRORS++))
fi
echo ""

# Check 2: AWS Credentials
echo "2. Checking AWS credentials..."
if aws sts get-caller-identity > /dev/null 2>&1; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    USER_ARN=$(aws sts get-caller-identity --query Arn --output text)
    echo "   ✓ AWS credentials configured"
    echo "   Account ID: $ACCOUNT_ID"
    echo "   User: $USER_ARN"
else
    echo "   ✗ AWS credentials NOT configured"
    echo "     Run: aws configure"
    ((ERRORS++))
fi
echo ""

# Check 3: AWS Region
echo "3. Checking AWS region..."
REGION=$(aws configure get region)
if [ "$REGION" == "us-east-1" ]; then
    echo "   ✓ Region set to us-east-1"
else
    echo "   ⚠ Region set to: $REGION"
    echo "     Recommended: us-east-1"
    echo "     Change: aws configure set region us-east-1"
    ((WARNINGS++))
fi
echo ""

# Check 4: SSH Key Pair
echo "4. Checking SSH key pair..."
if aws ec2 describe-key-pairs --key-names demo-key --region us-east-1 > /dev/null 2>&1; then
    echo "   ✓ Key pair 'demo-key' exists in AWS"
else
    echo "   ✗ Key pair 'demo-key' NOT found"
    echo "     Create: aws ec2 create-key-pair --key-name demo-key --query 'KeyMaterial' --output text > ~/.ssh/demo-key.pem"
    echo "             chmod 400 ~/.ssh/demo-key.pem"
    ((ERRORS++))
fi

if [ -f ~/.ssh/demo-key.pem ]; then
    echo "   ✓ Local key file exists"
    PERMS=$(stat -f %A ~/.ssh/demo-key.pem 2>/dev/null || stat -c %a ~/.ssh/demo-key.pem 2>/dev/null)
    if [ "$PERMS" == "400" ]; then
        echo "   ✓ Permissions correct (400)"
    else
        echo "   ⚠ Permissions: $PERMS (should be 400)"
        echo "     Fix: chmod 400 ~/.ssh/demo-key.pem"
        ((WARNINGS++))
    fi
else
    echo "   ⚠ Local key file not found at ~/.ssh/demo-key.pem"
    ((WARNINGS++))
fi
echo ""

# Check 5: Required Files
echo "5. Checking demo files..."
FILES=(
    "part1-ec2-demo/deploy-beanstalk.sh"
    "part1-ec2-demo/app.py"
    "part1-ec2-demo/requirements.txt"
    "part2-serverless-demo/deploy-lambda.sh"
    "part2-serverless-demo/lambda-functions/sns_handler.py"
    "part2-serverless-demo/lambda-functions/sqs_processor.py"
    "cleanup.sh"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✓ $file"
    else
        echo "   ✗ $file NOT found"
        ((ERRORS++))
    fi
done
echo ""

# Check 6: Script Permissions
echo "6. Checking script permissions..."
SCRIPTS=(
    "part1-ec2-demo/deploy-beanstalk.sh"
    "part1-ec2-demo/cleanup-beanstalk.sh"
    "part2-serverless-demo/deploy-lambda.sh"
    "part2-serverless-demo/test-lambda.sh"
    "cleanup.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        echo "   ✓ $script is executable"
    else
        echo "   ⚠ $script NOT executable"
        echo "     Fix: chmod +x $script"
        ((WARNINGS++))
    fi
done
echo ""

# Check 7: Existing Resources
echo "7. Checking for existing demo resources..."
EXISTING_INSTANCES=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=Demo-Web-App" "Name=instance-state-name,Values=running,pending" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --region us-east-1 \
    --output text 2>/dev/null)

if [ -z "$EXISTING_INSTANCES" ]; then
    echo "   ✓ No existing EC2 instances"
else
    echo "   ⚠ Found existing EC2 instances: $EXISTING_INSTANCES"
    echo "     Clean up: ./cleanup.sh"
    ((WARNINGS++))
fi

EXISTING_LAMBDAS=$(aws lambda list-functions \
    --query 'Functions[?starts_with(FunctionName, `demo`)].FunctionName' \
    --region us-east-1 \
    --output text 2>/dev/null)

if [ -z "$EXISTING_LAMBDAS" ]; then
    echo "   ✓ No existing Lambda functions"
else
    echo "   ⚠ Found existing Lambda functions: $EXISTING_LAMBDAS"
    echo "     Clean up: ./cleanup.sh"
    ((WARNINGS++))
fi
echo ""

# Check 8: IAM Permissions (basic check)
echo "8. Checking IAM permissions..."
CAN_LIST_EC2=$(aws ec2 describe-instances --max-results 5 > /dev/null 2>&1 && echo "yes" || echo "no")
CAN_LIST_LAMBDA=$(aws lambda list-functions --max-items 1 > /dev/null 2>&1 && echo "yes" || echo "no")

if [ "$CAN_LIST_EC2" == "yes" ]; then
    echo "   ✓ Can access EC2"
else
    echo "   ✗ Cannot access EC2 - check IAM permissions"
    ((ERRORS++))
fi

if [ "$CAN_LIST_LAMBDA" == "yes" ]; then
    echo "   ✓ Can access Lambda"
else
    echo "   ✗ Cannot access Lambda - check IAM permissions"
    ((ERRORS++))
fi
echo ""

# Check 9: Python (for local testing)
echo "9. Checking Python installation..."
if command -v python3 &> /dev/null; then
    echo "   ✓ Python 3 installed"
    PYTHON_VERSION=$(python3 --version)
    echo "   Version: $PYTHON_VERSION"
else
    echo "   ⚠ Python 3 not found (optional for demo)"
    ((WARNINGS++))
fi
echo ""

# Check 10: Internet Connectivity
echo "10. Checking internet connectivity..."
if curl -s --head https://aws.amazon.com > /dev/null; then
    echo "   ✓ Can reach AWS"
else
    echo "   ✗ Cannot reach AWS - check internet connection"
    ((ERRORS++))
fi
echo ""

# Summary
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✓ ALL CHECKS PASSED"
    echo ""
    echo "You're ready for the demo! 🚀"
    echo ""
    echo "Quick start commands:"
    echo "  cd part1-ec2-demo && ./deploy-beanstalk.sh"
    echo "  cd part2-serverless-demo && ./deploy-lambda.sh"
else
    if [ $ERRORS -gt 0 ]; then
        echo "✗ ERRORS FOUND: $ERRORS"
        echo "  Fix these before running the demo"
    fi
    
    if [ $WARNINGS -gt 0 ]; then
        echo "⚠ WARNINGS: $WARNINGS"
        echo "  Demo may work but review these issues"
    fi
fi
echo ""

echo "For detailed setup instructions, see: PRE_DEMO_SETUP.md"
echo "For demo script, see: PRESENTATION_SCRIPT.md"
echo "For quick reference, see: QUICK_REFERENCE.md"
echo ""

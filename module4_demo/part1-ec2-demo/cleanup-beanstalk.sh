#!/bin/bash

#===============================================================================
# Elastic Beanstalk + S3 Cleanup Script
# This script removes all resources created by the deployment script
#===============================================================================

echo "======================================================================"
echo "AWS Demo Cleanup - Elastic Beanstalk + S3"
echo "======================================================================"
echo ""

# Load configuration
if [ -f ".eb-demo-config" ]; then
    source .eb-demo-config
    echo "✓ Loaded configuration from .eb-demo-config"
else
    echo "⚠ No configuration file found. Please provide details manually:"
    read -p "Enter Application Name [demo-webapp]: " APP_NAME
    APP_NAME=${APP_NAME:-demo-webapp}
    read -p "Enter Environment Name [demo-webapp-env]: " ENV_NAME
    ENV_NAME=${ENV_NAME:-demo-webapp-env}
    read -p "Enter S3 Bucket Name: " S3_BUCKET
fi

echo ""
echo "⚠️  This will delete ALL demo resources:"
echo "   - Elastic Beanstalk environment: $ENV_NAME"
echo "   - Elastic Beanstalk application: $APP_NAME"
echo "   - S3 bucket: $S3_BUCKET (demo app files)"
echo ""
echo "ℹ️  NOTE: Elastic Beanstalk platform bucket (elasticbeanstalk-*) will NOT be deleted."
echo "   - Protected by bucket policy (cannot be deleted)"
echo "   - Shared across all EB applications in the region"
echo "   - Application versions will be cleaned from it"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Starting cleanup..."
echo "======================================================================"

# Step 1: Terminate Elastic Beanstalk environment
echo ""
echo "Step 1: Terminating Elastic Beanstalk environment..."
echo "----------------------------------------------------------------------"

if aws elasticbeanstalk describe-environments \
    --application-name $APP_NAME \
    --environment-names $ENV_NAME \
    --query 'Environments[0].EnvironmentName' \
    --output text 2>/dev/null | grep -q "$ENV_NAME"; then
    
    echo "Terminating environment: $ENV_NAME"
    echo "This may take 3-5 minutes..."
    
    eb terminate $ENV_NAME --force 2>&1 | grep -v "WARNING" || \
    aws elasticbeanstalk terminate-environment \
        --environment-name $ENV_NAME \
        2>/dev/null || echo "  Environment termination initiated"
    
    # Wait for termination
    echo "Waiting for environment to terminate..."
    sleep 30
    
    echo "✓ Environment termination initiated"
else
    echo "⚠ Environment not found"
fi

# Step 2: Delete Elastic Beanstalk application
echo ""
echo "Step 2: Deleting Elastic Beanstalk application..."
echo "----------------------------------------------------------------------"

if aws elasticbeanstalk describe-applications \
    --application-names $APP_NAME \
    --query 'Applications[0].ApplicationName' \
    --output text 2>/dev/null | grep -q "$APP_NAME"; then
    
    echo "Cleaning up application versions from EB storage bucket..."
    # Get all application versions
    APP_VERSIONS=$(aws elasticbeanstalk describe-application-versions \
        --application-name $APP_NAME \
        --query 'ApplicationVersions[*].VersionLabel' \
        --output text 2>/dev/null)
    
    if [ -n "$APP_VERSIONS" ]; then
        for VERSION in $APP_VERSIONS; do
            aws elasticbeanstalk delete-application-version \
                --application-name $APP_NAME \
                --version-label "$VERSION" \
                --delete-source-bundle \
                2>/dev/null || true
        done
        echo "  ✓ Application versions cleaned from EB storage bucket"
    fi
    
    echo "Deleting application..."
    aws elasticbeanstalk delete-application \
        --application-name $APP_NAME \
        --terminate-env-by-force \
        2>/dev/null && echo "✓ Application deleted" || echo "⚠ Application deletion pending"
else
    echo "⚠ Application not found"
fi

# Step 3: Empty and delete S3 bucket
echo ""
echo "Step 3: Deleting S3 bucket..."
echo "----------------------------------------------------------------------"

if aws s3 ls s3://$S3_BUCKET 2>/dev/null; then
    echo "Emptying bucket..."
    aws s3 rm s3://$S3_BUCKET --recursive 2>/dev/null || true
    
    echo "Deleting bucket..."
    aws s3 rb s3://$S3_BUCKET --force 2>/dev/null && \
        echo "✓ S3 bucket deleted" || \
        echo "⚠ S3 bucket deletion failed (may need manual cleanup)"
else
    echo "⚠ S3 bucket not found"
fi

# Step 4: Remove IAM instance profile and role
echo ""
echo "Step 4: Cleaning up IAM role and instance profile..."
echo "----------------------------------------------------------------------"

IAM_ROLE="${IAM_ROLE:-aws-elasticbeanstalk-ec2-role-demo}"

# Remove role from instance profile
if aws iam get-instance-profile --instance-profile-name "$IAM_ROLE" &>/dev/null; then
    echo "Removing role from instance profile..."
    aws iam remove-role-from-instance-profile \
        --instance-profile-name "$IAM_ROLE" \
        --role-name "$IAM_ROLE" \
        2>/dev/null && echo "  ✓ Role removed from instance profile" || true
    
    # Delete instance profile
    aws iam delete-instance-profile \
        --instance-profile-name "$IAM_ROLE" \
        2>/dev/null && echo "  ✓ Instance profile deleted" || true
fi

# Delete inline policies
if aws iam get-role --role-name "$IAM_ROLE" &>/dev/null; then
    echo "Removing inline policies..."
    aws iam delete-role-policy \
        --role-name "$IAM_ROLE" \
        --policy-name S3BucketAccess \
        2>/dev/null && echo "  ✓ S3BucketAccess policy removed" || true
    
    # Detach managed policies
    echo "Detaching managed policies..."
    aws iam detach-role-policy \
        --role-name "$IAM_ROLE" \
        --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier \
        2>/dev/null || true
    
    aws iam detach-role-policy \
        --role-name "$IAM_ROLE" \
        --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker \
        2>/dev/null || true
    
    aws iam detach-role-policy \
        --role-name "$IAM_ROLE" \
        --policy-arn arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier \
        2>/dev/null || true
    
    echo "  ✓ Managed policies detached"
    
    # Delete role
    aws iam delete-role \
        --role-name "$IAM_ROLE" \
        2>/dev/null && echo "  ✓ IAM role deleted" || echo "  ⚠ IAM role deletion failed"
else
    echo "⚠ IAM role not found"
fi

# Step 5: Clean up local files
echo ""
echo "Step 5: Cleaning up local files..."
echo "----------------------------------------------------------------------"

rm -f .eb-demo-config 2>/dev/null && echo "✓ Removed .eb-demo-config" || true
rm -f app-*.zip 2>/dev/null && echo "✓ Removed application bundles" || true
rm -rf .elasticbeanstalk/ 2>/dev/null && echo "✓ Removed .elasticbeanstalk directory" || true

echo ""
echo "======================================================================"
echo "✅ Cleanup Complete!"
echo "======================================================================"
echo ""
echo "All resources have been removed or scheduled for deletion."
echo ""
echo "📋 Resources Cleaned:"
echo "   ✓ Elastic Beanstalk environment terminated"
echo "   ✓ Elastic Beanstalk application deleted"
echo "   ✓ Application versions removed from EB storage bucket"
echo "   ✓ Demo S3 bucket deleted: $S3_BUCKET"
echo "   ✓ IAM role and instance profile deleted"
echo "   ✓ Local configuration files removed"
echo ""
echo "ℹ️  About the EB Platform Bucket:"
echo "   The bucket 'elasticbeanstalk-us-east-1-*' is shared across all"
echo "   Elastic Beanstalk applications in your region and is protected"
echo "   by a deletion policy. It cannot and should not be deleted."
echo "   Application versions have been cleaned from it."
echo ""
echo "======================================================================"

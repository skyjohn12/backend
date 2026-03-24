# Common Issues and Quick Fixes

## 🚨 Most Common Problems Students Face

### 1. SQS Not Triggering Lambda (Event Source Mapping Disabled)

**Symptoms:**
- SQS queue receives messages
- Lambda function never executes
- No CloudWatch logs appear
- `verify-homework.sh` shows "SQS trigger exists but is DISABLED"

**Root Cause:**
The event source mapping was created but is in "Disabled" state.

**Quick Fix:**
```bash
# Get the mapping UUID
UUID=$(aws lambda list-event-source-mappings --function-name task-validator --query 'EventSourceMappings[0].UUID' --output text)

# Enable it
aws lambda update-event-source-mapping --uuid $UUID --enabled

# Verify it's enabled
aws lambda list-event-source-mappings --function-name task-validator --query 'EventSourceMappings[0].State'
```

**Prevention:**
Always use `--enabled` flag when creating event source mappings:
```bash
aws lambda create-event-source-mapping \
  --function-name task-validator \
  --event-source-arn arn:aws:sqs:us-east-1:ACCOUNT:task-processing-queue \
  --batch-size 10 \
  --enabled  # <-- DON'T FORGET THIS!
```

---

### 2. Lambda Triggered Multiple Times (Duplicate SNS Subscriptions)

**Symptoms:**
- Single SNS message triggers Lambda twice
- Two separate log streams created for same message
- `verify-homework.sh` shows "duplicate subscriptions"
- Double notifications received

**Root Cause:**
Running deployment script multiple times creates duplicate SNS subscriptions.

**Quick Fix:**
```bash
# List all subscriptions
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:ACCOUNT:task-notifications

# Delete duplicate subscriptions (keep only one)
aws sns unsubscribe --subscription-arn arn:aws:sns:...:DUPLICATE-ID
```

**Prevention:**
Check before creating subscription:
```bash
# Check if subscription exists
EXISTING=$(aws sns list-subscriptions-by-topic \
  --topic-arn $SNS_TOPIC_ARN \
  --query "Subscriptions[?Protocol=='lambda' && Endpoint=='$LAMBDA_ARN']" \
  --output text)

# Only create if none exist
if [ -z "$EXISTING" ]; then
  aws sns subscribe --topic-arn $SNS_TOPIC_ARN --protocol lambda --notification-endpoint $LAMBDA_ARN
fi
```

---

### 3. Email Notifications Not Received

**Symptoms:**
- No emails arriving
- SNS topic exists and has email subscription
- No errors in logs

**Common Causes & Fixes:**

1. **Subscription not confirmed**
   ```bash
   # Check subscription status
   aws sns list-subscriptions-by-topic --topic-arn YOUR-TOPIC-ARN
   # Look for "PendingConfirmation" - check your email spam folder!
   ```

2. **Wrong email address**
   ```bash
   # Delete wrong subscription
   aws sns unsubscribe --subscription-arn WRONG-SUBSCRIPTION-ARN
   
   # Create new one with correct email
   aws sns subscribe --topic-arn YOUR-TOPIC-ARN --protocol email --notification-endpoint correct@email.com
   ```

---

### 4. Lambda Can't Access SQS/SNS (IAM Permissions)

**Symptoms:**
- "Access Denied" errors in CloudWatch logs
- Lambda executes but fails to read from SQS
- Lambda can't publish to SNS

**Quick Fix:**
```bash
# Verify IAM role has required policies
aws iam list-attached-role-policies --role-name task-lambda-execution-role

# Should show:
# - AWSLambdaBasicExecutionRole
# - AmazonSQSFullAccess (or custom SQS permissions)
# - AmazonSNSFullAccess (or custom SNS permissions)

# If missing, attach them:
aws iam attach-role-policy --role-name task-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess

aws iam attach-role-policy --role-name task-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSNSFullAccess
```

---

### 5. No CloudWatch Logs Appearing

**Symptoms:**
- Lambda executes but no logs visible
- Can't debug issues

**Quick Fix:**
```bash
# Ensure IAM role has CloudWatch Logs permissions
aws iam attach-role-policy --role-name task-lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# View logs
aws logs tail /aws/lambda/task-validator --follow
```

---

### 6. "Unable to import module" Error

**Symptoms:**
- Lambda fails immediately with import error
- CloudWatch shows: "Unable to import module 'task_validator'"

**Cause:** Incorrect zip file structure

**Fix:**
```bash
# WRONG - file inside subdirectory
zip task_validator.zip lambda-functions/task_validator.py

# CORRECT - file at root of zip
cd lambda-functions
zip task_validator.zip task_validator.py
cd ..
```

---

## 🔍 Debugging Checklist

When something doesn't work:

1. ✅ Check `verify-homework.sh` output for specific issues
2. ✅ Check CloudWatch logs: `aws logs tail /aws/lambda/FUNCTION-NAME --follow`
3. ✅ Verify event source mapping state (enabled/disabled)
4. ✅ Check for duplicate SNS subscriptions
5. ✅ Confirm IAM role has all required policies
6. ✅ Test Lambda function directly in AWS Console first
7. ✅ Verify environment variables are set correctly

---

## 📞 Still Stuck?

1. Review the demo code in `module4_demo/part2-serverless-demo/`
2. Check AWS Console for visual confirmation of resources
3. Compare your setup with working demo configuration
4. Ask instructor or TA with specific error messages from CloudWatch logs

---

## 💡 Pro Tips

- **Always use `--enabled` flag** when creating event source mappings
- **Check for existing subscriptions** before creating new ones
- **Test each Lambda individually** before integrating
- **Use CloudWatch Logs** extensively for debugging
- **Run `verify-homework.sh`** after each major change
- **Delete and recreate** if something is badly misconfigured (faster than fixing sometimes)

---

*This guide covers 95% of issues students encounter. Keep this handy!*

# Sample Test Events for Lambda Functions

## For task_validator Lambda

### Test Event 1: Valid Task (SQS format)
Save as `test-task-validator.json`:

```json
{
  "Records": [
    {
      "messageId": "test-msg-12345",
      "receiptHandle": "test-receipt-handle",
      "body": "{\"task_id\": \"task-001\", \"title\": \"Fix critical bug\", \"description\": \"The login page is not working for mobile users\", \"priority\": \"high\", \"created_at\": \"2024-01-15T10:30:00Z\", \"status\": \"pending\"}",
      "attributes": {
        "ApproximateReceiveCount": "1",
        "SentTimestamp": "1705316400000"
      },
      "messageAttributes": {},
      "md5OfBody": "test-md5",
      "eventSource": "aws:sqs",
      "eventSourceARN": "arn:aws:sqs:us-east-1:123456789012:task-processing-queue",
      "awsRegion": "us-east-1"
    }
  ]
}
```

### Test Event 2: Invalid Task (missing fields)
```json
{
  "Records": [
    {
      "messageId": "test-msg-67890",
      "receiptHandle": "test-receipt-handle-2",
      "body": "{\"task_id\": \"task-002\", \"title\": \"Incomplete task\"}",
      "attributes": {
        "ApproximateReceiveCount": "1",
        "SentTimestamp": "1705316500000"
      },
      "messageAttributes": {},
      "md5OfBody": "test-md5-2",
      "eventSource": "aws:sqs",
      "eventSourceARN": "arn:aws:sqs:us-east-1:123456789012:task-processing-queue",
      "awsRegion": "us-east-1"
    }
  ]
}
```

---

## For task_notifier Lambda

### Test Event 3: High Priority Task Notification (SNS format)
Save as `test-task-notifier.json`:

```json
{
  "Records": [
    {
      "EventSource": "aws:sns",
      "EventVersion": "1.0",
      "EventSubscriptionArn": "arn:aws:sns:us-east-1:123456789012:task-notifications:test-sub-id",
      "Sns": {
        "Type": "Notification",
        "MessageId": "test-sns-msg-123",
        "TopicArn": "arn:aws:sns:us-east-1:123456789012:task-notifications",
        "Subject": "High Priority Task Created",
        "Message": "{\"task_id\": \"task-003\", \"title\": \"Production server down\", \"priority\": \"high\", \"created_at\": \"2024-01-15T11:00:00Z\"}",
        "Timestamp": "2024-01-15T11:00:00.000Z",
        "SignatureVersion": "1",
        "Signature": "test-signature",
        "SigningCertUrl": "https://sns.us-east-1.amazonaws.com/test-cert.pem",
        "UnsubscribeUrl": "https://sns.us-east-1.amazonaws.com/test-unsub"
      }
    }
  ]
}
```

### Test Event 4: Plain Text Notification
```json
{
  "Records": [
    {
      "EventSource": "aws:sns",
      "EventVersion": "1.0",
      "EventSubscriptionArn": "arn:aws:sns:us-east-1:123456789012:task-notifications:test-sub-id-2",
      "Sns": {
        "Type": "Notification",
        "MessageId": "test-sns-msg-456",
        "TopicArn": "arn:aws:sns:us-east-1:123456789012:task-notifications",
        "Subject": "Test Notification",
        "Message": "This is a plain text notification for testing",
        "Timestamp": "2024-01-15T11:05:00.000Z",
        "SignatureVersion": "1",
        "Signature": "test-signature-2",
        "SigningCertUrl": "https://sns.us-east-1.amazonaws.com/test-cert.pem",
        "UnsubscribeUrl": "https://sns.us-east-1.amazonaws.com/test-unsub"
      }
    }
  ]
}
```

---

## How to Test Lambda Functions Locally

### Using AWS CLI

#### Test task-validator:
```bash
cd lambda-functions

# Test with valid task
aws lambda invoke \
  --function-name task-validator \
  --payload file://test-task-validator.json \
  --cli-binary-format raw-in-base64-out \
  output.json

# View the result
cat output.json
```

#### Test task-notifier:
```bash
# Test with notification
aws lambda invoke \
  --function-name task-notifier \
  --payload file://test-task-notifier.json \
  --cli-binary-format raw-in-base64-out \
  output.json

# View the result
cat output.json
```

### Check CloudWatch Logs
```bash
# For task-validator
aws logs tail /aws/lambda/task-validator --follow

# For task-notifier
aws logs tail /aws/lambda/task-notifier --follow
```

---

## Testing Tips

1. **Start with valid data**: Make sure your Lambda functions work with correct input first
2. **Test error cases**: Then try invalid data to verify error handling
3. **Check CloudWatch**: Always verify logs are written correctly
4. **Use AWS Console**: The Lambda console has a built-in test feature
5. **Test incrementally**: Test each TODO as you complete it

---

## Common Issues and Solutions

### Issue: "Unable to import module"
**Solution**: Make sure you're zipping the Python file correctly:
```bash
zip function.zip function.py
# NOT: zip function.zip folder/function.py
```

### Issue: "null" response
**Solution**: Check that you're returning a dict with 'statusCode' and 'body'

### Issue: Environment variables not found
**Solution**: This homework doesn't require environment variables. If you need them for extensions:
```bash
aws lambda update-function-configuration \
  --function-name task-validator \
  --environment Variables={AWS_REGION=us-east-1}
```

### Issue: Logs not appearing
**Solution**: Wait a few seconds, then check again. Or use `--follow` flag:
```bash
aws logs tail /aws/lambda/task-validator --follow
```

---

## Quick Test Checklist

- [ ] Lambda function code has no syntax errors
- [ ] Function is packaged correctly (zip file)
- [ ] Function is deployed to AWS
- [ ] Environment variables are set (if needed)
- [ ] Test event JSON is valid
- [ ] Can invoke function via AWS CLI
- [ ] Function returns expected response
- [ ] Logs appear in CloudWatch
- [ ] Error cases are handled gracefully

---

Good luck with your testing! 🧪

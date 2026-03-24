#===============================================================================
# Homework Verification Script - PowerShell Version
# Tests if your AWS resources are properly configured
#===============================================================================

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "AWS Homework Verification" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$PASSED = 0
$FAILED = 0

function Check-Pass {
    param($message)
    Write-Host "✓ $message" -ForegroundColor Green
    $script:PASSED++
}

function Check-Fail {
    param($message)
    Write-Host "✗ $message" -ForegroundColor Red
    $script:FAILED++
}

function Check-Warn {
    param($message)
    Write-Host "⚠ $message" -ForegroundColor Yellow
}

Write-Host "Checking AWS Authentication..." -ForegroundColor Cyan
try {
    $accountId = aws sts get-caller-identity --query Account --output text 2>$null
    if ($accountId) {
        Check-Pass "AWS authentication successful (Account: $accountId)"
    } else {
        throw "Authentication failed"
    }
} catch {
    Check-Fail "AWS authentication failed"
    Write-Host "Run: aws-azure-login -m gui --no-sandbox"
    exit 1
}

Write-Host ""
Write-Host "Checking IAM Role..." -ForegroundColor Cyan
try {
    $roleArn = aws iam get-role --role-name task-lambda-execution-role --query Role.Arn --output text 2>$null
    if ($roleArn) {
        Check-Pass "IAM role 'task-lambda-execution-role' exists"
        
        # Check attached policies
        $policies = aws iam list-attached-role-policies --role-name task-lambda-execution-role --query 'AttachedPolicies[].PolicyName' --output text
        if ($policies -match "AWSLambdaBasicExecutionRole") {
            Check-Pass "Lambda execution policy attached"
        } else {
            Check-Fail "Lambda execution policy not attached"
        }
    } else {
        throw "Role not found"
    }
} catch {
    Check-Fail "IAM role 'task-lambda-execution-role' not found"
}

Write-Host ""
Write-Host "Checking SNS Topic..." -ForegroundColor Cyan
$snsTopics = aws sns list-topics --query "Topics[?contains(TopicArn, 'task-notifications')].TopicArn" --output text

if ($snsTopics) {
    Check-Pass "SNS topic 'task-notifications' exists"
    Write-Host "  Topic ARN: $snsTopics"
    
    # Check subscriptions
    $subs = aws sns list-subscriptions-by-topic --topic-arn $snsTopics --query 'Subscriptions[].Protocol' --output text
    if ($subs -match "email") {
        Check-Pass "Email subscription configured"
    } else {
        Check-Warn "No email subscription found - you won't receive notifications"
    }
} else {
    Check-Fail "SNS topic 'task-notifications' not found"
}

Write-Host ""
Write-Host "Checking SQS Queue..." -ForegroundColor Cyan
$queueUrl = aws sqs get-queue-url --queue-name task-processing-queue --query QueueUrl --output text 2>$null
if ($queueUrl) {
    Check-Pass "SQS queue 'task-processing-queue' exists"
    Write-Host "  Queue URL: $queueUrl"
} else {
    Check-Fail "SQS queue 'task-processing-queue' not found"
}

Write-Host ""
Write-Host "Checking Lambda Functions..." -ForegroundColor Cyan
$taskValidator = aws lambda get-function --function-name task-validator --query Configuration.FunctionName --output text 2>$null
if ($taskValidator) {
    Check-Pass "Lambda function 'task-validator' exists"
    
    # Check SQS trigger
    $eventSource = aws lambda list-event-source-mappings --function-name task-validator --query "EventSourceMappings[?contains(EventSourceArn, 'task-processing-queue')].UUID" --output text 2>$null
    if ($eventSource) {
        Check-Pass "task-validator has SQS trigger configured"
    } else {
        Check-Fail "task-validator missing SQS trigger"
    }
} else {
    Check-Fail "Lambda function 'task-validator' not found"
}

$taskNotifier = aws lambda get-function --function-name task-notifier --query Configuration.FunctionName --output text 2>$null
if ($taskNotifier) {
    Check-Pass "Lambda function 'task-notifier' exists"
} else {
    Check-Fail "Lambda function 'task-notifier' not found"
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Verification Summary" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Passed: $PASSED" -ForegroundColor Green
Write-Host "Failed: $FAILED" -ForegroundColor Red
Write-Host ""

if ($FAILED -eq 0) {
    Write-Host "🎉 All checks passed! Your homework is ready for submission." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "1. Review AWS console the logs of your Lambda functions"
    Write-Host "2. Ensure SNS notifications are received (if email subscribed)"
    Write-Host "3. Push your branch with your code changes"
} else {
    Write-Host "⚠️  Some checks failed. Please fix the issues above." -ForegroundColor Red
    Write-Host ""
    Write-Host "Common issues:"
    Write-Host "- Make sure you've created all required AWS resources"
    Write-Host "- Check IAM permissions"
    Write-Host "- Verify Lambda functions are deployed with correct names"
    Write-Host "- Ensure environment variables are set"
}

Write-Host ""
Write-Host "For detailed help, see README.md"

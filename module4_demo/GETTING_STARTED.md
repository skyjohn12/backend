# Getting Started - 5 Minute Setup

## Absolute Minimum to Get Started

### Step 1: Install AWS CLI (2 minutes)
```bash
# macOS
brew install awscli

# Verify
aws --version
```

### Step 2: Configure AWS (1 minute)
```bash
aws configure
# Enter: Access Key, Secret Key, Region (us-east-1), Format (json)
```

### Step 3: Create SSH Key (30 seconds)
```bash
aws ec2 create-key-pair --key-name demo-key --query 'KeyMaterial' --output text > ~/.ssh/demo-key.pem
chmod 400 ~/.ssh/demo-key.pem
```

### Step 4: Verify Everything Works (1 minute)
```bash
chmod +x verify-setup.sh
./verify-setup.sh
```

### Step 5: Run Your First Demo (30 seconds)
```bash
cd part1-ec2-demo
chmod +x deploy-beanstalk.sh
./deploy-beanstalk.sh
```

---

## That's It! 

In 5 minutes you're ready to:
- ✅ Deploy applications to Elastic Beanstalk with S3
- ✅ Create serverless Lambda functions
- ✅ Demonstrate cloud computing concepts
- ✅ Deliver your 20-minute presentation

---

## Next Steps

1. **Read**: `PRESENTATION_SCRIPT.md` for detailed talking points
2. **Prepare**: `QUICK_REFERENCE.md` for day-of reference
3. **Practice**: Run through both demos once
4. **Present**: Deliver your presentation with confidence!

---

## Important Reminders

⚠️ **Always clean up after demo**: `./cleanup.sh`  
💰 **Expected cost**: Less than $0.10 per demo  
🆓 **Free Tier**: Elastic Beanstalk free + 750 EC2 hours + 1M Lambda requests/month  
⏱️ **Demo duration**: 20 minutes total  

---

## Quick Command Reference

### Part 1: Elastic Beanstalk Demo
```bash
cd part1-ec2-demo
./deploy-beanstalk.sh                # Deploy
# Access: URL provided in output
./cleanup-beanstalk.sh               # Cleanup
```

### Part 2: Lambda Demo
```bash
cd part2-serverless-demo
./deploy-lambda.sh                # Deploy
./test-lambda.sh                  # Test
```

### Cleanup
```bash
./cleanup.sh                      # Clean everything
```

---

## Help & Troubleshooting

| Issue | Solution |
|-------|----------|
| AWS CLI not working | `brew reinstall awscli` |
| Permission denied | Check IAM user permissions |
| Key pair not found | Create with command in Step 3 |
| App not loading | Wait 2-3 minutes after deployment |
| Scripts not running | `chmod +x script-name.sh` |

---

## Files Overview

| File | Purpose |
|------|---------|
| `README.md` | Complete guide |
| `GETTING_STARTED.md` | This quick start (you are here) |
| `PRESENTATION_SCRIPT.md` | 20-min presentation with timing |
| `QUICK_REFERENCE.md` | Command cheat sheet |
| `PRE_DEMO_SETUP.md` | Detailed setup instructions |
| `DEMO_OVERVIEW.md` | Architecture overview |
| `verify-setup.sh` | Pre-flight check |
| `cleanup.sh` | Remove all resources |

---

## Ready to Present?

**Day Before:**
1. Run `./verify-setup.sh`
2. Test both demos
3. Review `PRESENTATION_SCRIPT.md`
4. Print `QUICK_REFERENCE.md`

**Day Of:**
1. Run `./cleanup.sh` (clean slate)
2. Set terminal font to 16-18pt
3. Open AWS Console
4. Have `QUICK_REFERENCE.md` ready
5. Deep breath - you've got this! 🚀

---

## Support

- 📖 Read the docs: All `.md` files in this repo
- 🔍 Check logs: `aws logs tail /aws/lambda/FUNCTION_NAME --follow`
- 🆘 AWS Support: console.aws.amazon.com/support
- 💬 Open issue: In this repository

---

**You're all set! Start with `./verify-setup.sh` to confirm everything is ready.**

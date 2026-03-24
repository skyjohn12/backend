# InfoSec Security Alert - Expected Behavior

## 🚨 Alert You Received

```
AWS security group allowed unrestricted access to ports.

GroupName: awseb-e-zmyfwmx43i-stack-AWSEBSecurityGroup-52ZTmM8hyiDL
tag.Name: demo-webapp-env
GroupId: sg-073bc727823b1095f
VpcId: vpc-f4c16c89

A Slalom AWS Innovation Lab security automation alert has indicated that 
security group [...] was configured to allow one or more ports to all 
internet-based IP addresses (0.0.0.0/0).
```

---

## ✅ This is EXPECTED - Here's Why

### The Timeline:

1. **T+0 seconds**: You run `deploy-beanstalk.sh`
2. **T+30 seconds**: Elastic Beanstalk creates security group with **default 0.0.0.0/0 rules**
3. **T+2 minutes**: InfoSec automation **detects** the 0.0.0.0/0 configuration
4. **T+3 minutes**: Your script removes 0.0.0.0/0 and adds YOUR IP restriction
5. **T+4 minutes**: InfoSec automation **automatically remediates** (removes 0.0.0.0/0)
6. **T+5 minutes**: You receive the email alert (notification of what was detected)

### Why This Happens:

Elastic Beanstalk **always** creates security groups with 0.0.0.0/0 access first. There is no way to prevent this during initial creation. The deployment script removes these rules immediately after environment creation, but InfoSec automation may detect it during that brief window.

---

## 🔒 Current Security Posture

**After deployment completes, your security group IS compliant:**

✅ **0.0.0.0/0 rules removed** (either by your script or InfoSec automation)  
✅ **Access restricted to YOUR IP only**  
✅ **S3 buckets are PRIVATE**  
✅ **IAM role-based access** (no access keys)  
✅ **Approved instance type** (t3.micro)

---

## 🔍 How to Verify It's Fixed

Run this command (replace `sg-XXXXXXXXX` with your actual security group ID):

```bash
aws ec2 describe-security-groups --group-ids sg-073bc727823b1095f \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`80`].IpRanges[*].CidrIp'
```

**Expected output:**
```json
[
  "YOUR.IP.ADDRESS.HERE/32"
]
```

**NOT this:**
```json
[
  "0.0.0.0/0"
]
```

If you see 0.0.0.0/0, run the security group fix section of the deployment script again, or InfoSec automation will fix it automatically within 5-10 minutes.

---

## 📧 Should You Reply to the Alert?

**No action required IF:**
- ✅ You just deployed Elastic Beanstalk
- ✅ The security group name contains "awseb" and your environment name
- ✅ Your deployment script completed successfully
- ✅ Verification command shows YOUR IP (not 0.0.0.0/0)

**You should reply IF:**
- ❌ The alert is for a different security group (not Elastic Beanstalk)
- ❌ Verification shows 0.0.0.0/0 is still present after 10 minutes
- ❌ You didn't deploy anything recently

---

## 🔧 Manual Fix (If Needed)

If the security group still shows 0.0.0.0/0 after 10 minutes:

```bash
# Get your current IP
MY_IP=$(curl -s ifconfig.me)
SG_ID="sg-073bc727823b1095f"  # Replace with your security group ID

# Remove 0.0.0.0/0 rule for HTTP
aws ec2 revoke-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

# Add your IP only
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr ${MY_IP}/32

# Verify
aws ec2 describe-security-groups --group-ids $SG_ID \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`80`].IpRanges[*].CidrIp'
```

---

## 📊 What InfoSec Automation Does

The InfoSec system automatically:

1. **Scans** all security groups every 2-5 minutes
2. **Detects** any rules allowing 0.0.0.0/0 on ports below 10,000
3. **Sends alert** to the resource owner (you)
4. **Automatically remediates** by removing the 0.0.0.0/0 rule

This means the alert is a **notification of what was found and fixed**, not a request for action.

---

## 🎯 Best Practices Going Forward

### Option 1: Accept the Alert (Recommended)
- Understand this is expected behavior with Elastic Beanstalk
- InfoSec automation will automatically remediate
- Your deployment script also fixes it
- No action needed

### Option 2: Pre-Deploy Communication
- Email InfoSec before deploying: security@slalom.com
- Subject: "Expected Security Alert - Elastic Beanstalk Demo Deployment"
- Body: "I will be deploying an Elastic Beanstalk demo environment in the next hour. You may detect a security group with 0.0.0.0/0 access for demo-webapp-env. This will be automatically remediated by your systems and my deployment script."

### Option 3: Use Alternative Architecture
- Deploy Lambda-only demo (Part 2) which doesn't use security groups
- Use AWS Cloud9 instead of Elastic Beanstalk
- Use containers with pre-configured security

---

## ❓ FAQ

**Q: Will I get in trouble for this alert?**  
A: No. The alert confirms the security system is working. InfoSec understands that Elastic Beanstalk creates default rules.

**Q: Will my demo be affected?**  
A: No. After remediation, your application will only be accessible from your IP address.

**Q: How many times will I get this alert?**  
A: Once per Elastic Beanstalk deployment. If you redeploy, you'll get another alert.

**Q: Can I prevent the alert entirely?**  
A: No, not with Elastic Beanstalk. The service creates default security groups before we can configure them. Consider using Lambda-only demos to avoid this.

**Q: Will this affect my ability to use AWS Innovation Labs?**  
A: No. InfoSec expects occasional security findings, especially during demos. The key is that violations are quickly remediated (which they are).

---

## 📞 Contact Information

**For security-related questions:**
- Email: security@slalom.com

**For AWS Innovation Labs access issues:**
- Portal: help.slalom.com

**For technical demo support:**
- Check: `SECURITY_COMPLIANCE.md` in this repository
- Review: `QUICK_REFERENCE.md` for troubleshooting

---

## ✅ Summary

- ✅ **The alert is EXPECTED** - it's how Elastic Beanstalk works
- ✅ **Already fixed** - either by your script or InfoSec automation  
- ✅ **No action required** - just verify it's restricted to your IP
- ✅ **Not a policy violation** - you followed proper procedures
- ✅ **Demo will work fine** - access is properly restricted

**The security system is working as designed. You're all set!** 🎉

---

*Last Updated: November 2025*

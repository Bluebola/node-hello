# Simple CI/CD Pipeline Setup

## Required GitHub Secrets

Add these to your GitHub repository (Settings → Secrets and variables → Actions):

### AWS_ACCESS_KEY_ID
Your AWS Access Key ID with permissions for:
- ECR (push/pull images)
- EC2 (describe instances) 
- SSM (send commands to EC2)

### AWS_SECRET_ACCESS_KEY
Your AWS Secret Access Key

## How It Works

The pipeline is triggered when you push to the `dev` branch:

1. **Test**: Runs `npm test` to verify code quality
2. **Build**: Creates Docker image and pushes to ECR with `latest` tag
3. **Deploy**: Uses AWS SSM to run commands on EC2:
   - Stop old container
   - Pull latest image from ECR
   - Start new container
4. **Verify**: Tests that application responds on port 3000

## Deployment Method

**AWS Systems Manager (SSM)** is used to remotely execute commands on the EC2 instance. This requires:

- EC2 instance has SSM Agent (pre-installed on Amazon Linux 2)
- EC2 instance has IAM role with `AmazonSSMManagedInstanceCore` policy
- Your AWS credentials have SSM permissions

## Testing the Pipeline

1. Make code changes
2. Push to dev branch: `git push origin dev`
3. Check GitHub Actions tab for pipeline status
4. Verify at your EC2 URL: http://[EC2-PUBLIC-IP]:3000

## Why This Approach?

- **No SSH required**: Uses AWS SSM instead of SSH keys
- **Minimal complexity**: Single job with essential steps only
- **ECR integration**: Automatically pulls latest image to EC2
- **Built-in verification**: Pipeline fails if deployment doesn't work
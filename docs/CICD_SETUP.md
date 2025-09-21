# Complete CI/CD Pipeline Setup

## Required GitHub Secrets

Add these to your GitHub repository (Settings → Secrets and variables → Actions):

### AWS_ACCESS_KEY_ID
Your AWS Access Key ID with permissions for:
- ECR (push/pull images)
- EC2 (describe instances) 
- SSM (send commands to EC2)
- Terraform (infrastructure management)

### AWS_SECRET_ACCESS_KEY
Your AWS Secret Access Key

## Pipeline Features

The pipeline is triggered when you push to the `dev` branch and includes:

### 1. **Testing**
- Runs `npm test` to verify code quality
- Ensures all unit and integration tests pass

### 2. **Infrastructure Management** 
- Detects changes to `infra/` folder
- Automatically runs `terraform init/plan/apply` if infrastructure changed
- Updates AWS resources as needed

### 3. **Application Deployment**
- Builds Docker image and pushes to ECR with `latest` tag (mutable)
- Uses AWS SSM to update EC2 container:
  - Stop old container
  - Pull latest image from ECR  
  - Start new container
- Verifies application responds on port 3000

## Key Improvements

- ✅ **Mutable ECR tags**: Can overwrite `latest` tag for simpler workflow
- ✅ **Infrastructure automation**: Terraform changes deploy automatically  
- ✅ **No SSH required**: Uses AWS SSM for secure remote deployment
- ✅ **End-to-end automation**: Code → Infrastructure → Application → Verification

## Deployment Methods

### Application Changes Only
```
Git Push → Tests → Docker Build → ECR Push → SSM Deploy → Verify
```

### Infrastructure + Application Changes  
```
Git Push → Tests → Terraform Apply → Docker Build → ECR Push → SSM Deploy → Verify
```

## Testing the Pipeline

1. **Application changes**: Edit Node.js code, push to dev branch
2. **Infrastructure changes**: Edit Terraform files in `infra/`, push to dev branch  
3. **Monitor**: Check GitHub Actions tab for pipeline status
4. **Verify**: Visit http://[EC2-PUBLIC-IP]:3000 to see changes

## Requirements

- EC2 instance with SSM Agent (pre-installed on Amazon Linux 2)
- EC2 IAM role with SSM and ECR permissions
- ECR repository set to mutable tags
- Terraform backend (S3 + DynamoDB) configured
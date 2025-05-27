# Manual Deployment Guide for AWS Cognito M2M Authentication

This guide provides detailed step-by-step instructions for manually deploying the AWS Cognito M2M Authentication using Terraform.

## Introduction

Machine-to-Machine (M2M) authentication enables platform-independent server-to-server communications without user interaction. This setup uses AWS Cognito with OAuth 2.0 Client Credentials flow to authorize API access with OAuth 2.0 scopes, providing secure M2M communication between services.

Unlike traditional user authentication, M2M authentication:
- Does not involve any human interaction
- Uses client credentials flow instead of user login flows
- Authorizes API access using OAuth 2.0 scopes
- Enables secure communication between different services and systems
- Works across different platforms and environments

## Prerequisites

### 1. Install Terraform

#### On Windows:
1. Download the Terraform ZIP file from the [official website](https://www.terraform.io/downloads.html)
2. Extract the ZIP file to a directory (e.g., `C:\terraform`)
3. Add the directory to your system's PATH environment variable
4. Verify the installation by opening a command prompt and running:
   ```
   terraform -version
   ```

#### On macOS (using Homebrew):
```bash
brew install terraform
```

#### On Linux (Ubuntu/Debian):
```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform
```

### 2. Install AWS CLI

#### On Windows:
1. Download the AWS CLI MSI installer from the [official website](https://aws.amazon.com/cli/)
2. Run the installer and follow the instructions
3. Verify the installation by opening a command prompt and running:
   ```
   aws --version
   ```

#### On macOS (using Homebrew):
```bash
brew install awscli
```

#### On Linux (Ubuntu/Debian):
```bash
sudo apt-get update && sudo apt-get install -y awscli
```

### 3. Set Up AWS Credentials

You need AWS credentials with appropriate permissions to create Cognito resources.

#### Option 1: Using AWS CLI
```bash
aws configure
```
You'll be prompted to enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., "us-east-1")
- Default output format (json recommended)

#### Option 2: Using environment variables
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

#### Option 3: Using AWS credentials file
Create or edit `~/.aws/credentials`:
```
[default]
aws_access_key_id = your-access-key
aws_secret_access_key = your-secret-key
```

And `~/.aws/config`:
```
[default]
region = us-east-1
```

## Deployment Steps

### 1. Prepare the Terraform Files

1. Create a new directory for your project:
   ```bash
   mkdir m2m-cognito && cd m2m-cognito
   ```

2. Copy the following files from this repository to your project directory:
   - `main.tf`
   - `variables.tf`

   You can download them individually or clone the entire repository:
   ```bash
   git clone https://github.com/your-repo/m2m-cognito.git
   cd m2m-cognito
   ```

### 2. Initialize Terraform

Initialize Terraform to download the required providers:

```bash
terraform init
```

This command will:
- Download the AWS provider plugin
- Set up the backend for storing Terraform state
- Prepare your working directory for other commands

### 3. Customize Variables (Optional)

You can customize the deployment by modifying the variables in `variables.tf` or by creating a new file called `terraform.tfvars` with your custom values:

```
environment_name = "dev"
aws_region = "us-east-1"
user_pool_name_prefix = "machine-to-machine"
domain_prefix = "m2m-rubicon"
project_tag = "m2m-auth"
```

### 4. Preview the Deployment Plan

Generate and review the execution plan:

```bash
terraform plan
```

This command will:
- Show what changes Terraform will make to your infrastructure
- Identify any potential issues before applying changes
- Display a summary of resources to be created, modified, or destroyed

### 5. Apply the Configuration

Deploy the resources to AWS:

```bash
terraform apply
```

When prompted, type `yes` to confirm the deployment.

If you want to apply with custom variables without editing files:

```bash
terraform apply -var="environment_name=dev" -var="aws_region=us-west-2"
```

### 6. Verify the Deployment

After the deployment completes successfully, verify your resources:

1. Verify in AWS Console:
   - Log in to the [AWS Console](https://console.aws.amazon.com/)
   - Navigate to Amazon Cognito service
   - Confirm your user pool is created with the correct name
   - Check that the app client and resource server are configured correctly

### 7. Test the M2M Authentication

1. Get the client ID from the AWS Cognito console.

2. Get the client secret from AWS CLI (replace the placeholders with actual values):
   ```bash
   aws cognito-idp describe-user-pool-client \
     --user-pool-id <user_pool_id> \
     --client-id <client_id> \
     --query "UserPoolClient.ClientSecret" \
     --output text
   ```

3. Request an access token (replace the placeholders with actual values):
   ```bash
   curl -X POST \
     --user <client_id>:<client_secret> \
     -d 'grant_type=client_credentials&scope=m2m-client/read m2m-client/write' \
     https://<domain>.auth.<region>.amazoncognito.com/oauth2/token
   ```

## Making Changes to the Configuration

If you need to modify the configuration:

1. Edit the relevant Terraform files (`main.tf`, `variables.tf`, etc.)
2. Run `terraform plan` to preview the changes
3. Run `terraform apply` to apply the changes

## Troubleshooting

### Common Issues and Solutions

1. **Error: No valid credential sources found**
   - Ensure AWS credentials are properly configured
   - Try using a different credential method (environment variables, AWS CLI, etc.)

2. **Error: Domain name already exists**
   - Edit the domain prefix in variables.tf or use a different environment name
   - Run `terraform apply` again

3. **Error: Provider configuration not present**
   - Run `terraform init` to initialize the providers

4. **Error: Error acquiring the state lock**
   - Wait a few minutes and try again
   - If the issue persists, you may need to manually release the lock

5. **Permission errors**
   - Ensure your AWS credentials have sufficient permissions
   - Required permissions: `AmazonCognitoPowerUser` or equivalent custom policy

6. **Error: InvalidClientTokenId**
   - This error indicates that the security token included in the request is invalid
   - Run the included test script to verify your AWS credentials:
     ```bash
     chmod +x test_aws_credentials.sh
     ./test_aws_credentials.sh
     ```
   - Verify that your AWS credentials are correctly configured using one of the methods in the "Set Up AWS Credentials" section
   - Ensure your credentials have not expired
   - Check that you're using the correct AWS region
   - Run `aws sts get-caller-identity` to verify your credentials are working
   - If using environment variables, verify they are correctly set with `echo $AWS_ACCESS_KEY_ID`
   - As a last resort, you can uncomment and set the access_key and secret_key in main.tf (not recommended for production)

## Cleaning Up Resources

When you no longer need the AWS resources, destroy them to avoid incurring charges:

```bash
terraform destroy
```

When prompted, type `yes` to confirm the destruction of resources.

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs/index.html)
- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito/latest/developerguide/what-is-amazon-cognito.html)
- [AWS CLI Documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

# AWS Cognito M2M Authentication Terraform Configuration

This Terraform configuration sets up an AWS Cognito User Pool specifically configured for Machine-to-Machine (M2M) authentication.

## Overview

Machine-to-Machine (M2M) authentication is used when one service needs to authenticate with another service without human intervention. This setup uses AWS Cognito with OAuth 2.0 Client Credentials flow to enable secure M2M communication.

> **Important**: This configuration is strictly for M2M authentication and does not include any email or end-user authentication features. All email-related configurations and user password authentication flows have been removed to ensure this is a pure M2M setup.

## Resources Created

This Terraform configuration creates:

1. AWS Cognito User Pool
2. App Client configured for Client Credentials flow
3. Resource Server with read and write scopes
4. User Pool Domain with managed login
5. All necessary configurations for M2M authentication

## Prerequisites

- AWS account with appropriate permissions
- Terraform installed (version 0.12 or later)
- AWS CLI installed (optional, for testing)

## Deployment to AWS

### Setting up AWS Credentials

Before deploying, you need to set up your AWS credentials:

1. **Install AWS CLI** (if not already installed):
   - Follow the [official AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

2. **Configure AWS credentials** using one of these methods:

   a. Using AWS CLI:
   ```bash
   aws configure
   ```
   You'll be prompted to enter:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name (e.g., "us-east-1")
   - Default output format (json recommended)

   b. Using environment variables:
   ```bash
   export AWS_ACCESS_KEY_ID="your-access-key"
   export AWS_SECRET_ACCESS_KEY="your-secret-key"
   export AWS_DEFAULT_REGION="us-east-1"
   ```

   c. Using AWS credentials file:
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

### Deployment Steps

For detailed step-by-step manual deployment instructions, please refer to the [MANUAL_DEPLOYMENT.md](./MANUAL_DEPLOYMENT.md) file.

Quick start:

1. Clone this repository
2. Navigate to the repository directory
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review the plan:
   ```bash
   terraform plan
   ```
5. Apply the configuration:
   ```bash
   terraform apply
   ```

   You can also specify variables during apply:
   ```bash
   terraform apply -var="environment_name=dev" -var="aws_region=us-west-2"
   ```

### Verification

After deployment completes, verify your resources:

1. Verify in AWS Console:
   - Log in to the [AWS Console](https://console.aws.amazon.com/)
   - Navigate to Amazon Cognito service
   - Confirm your user pool is created with the correct name
   - Check that the app client and resource server are configured correctly

### Troubleshooting

Common issues and solutions:

1. **Domain name already exists**: The domain names must be globally unique. If deployment fails with a domain conflict:
   - Edit the domain prefix in variables.tf or use a different environment name
   - Redeploy the configuration

2. **Permission errors**: Ensure your AWS credentials have sufficient permissions:
   - Required permissions: `AmazonCognitoPowerUser` or equivalent custom policy
   - If using a custom policy, ensure it includes all necessary Cognito permissions

3. **InvalidClientTokenId error**: If you see an error like "The security token included in the request is invalid":
   - Run the included `test_aws_credentials.sh` script to verify your AWS credentials:
     ```bash
     chmod +x test_aws_credentials.sh
     ./test_aws_credentials.sh
     ```
   - Verify that your AWS credentials are correctly configured using one of the methods in the "Setting up AWS Credentials" section
   - Ensure your credentials have not expired
   - Check that you're using the correct AWS region
   - If using AWS CLI, run `aws sts get-caller-identity` to verify your credentials are working
   - If using environment variables, verify they are correctly set with `echo $AWS_ACCESS_KEY_ID`
   - As a last resort, you can uncomment and set the access_key and secret_key in main.tf (not recommended for production)

## Using the M2M Authentication

After deployment, you can obtain an access token using the Client Credentials flow:

1. Get the client ID and client secret from the AWS Cognito console.

   For the client secret, you can also use the AWS CLI (replace the placeholders with actual values):
   ```bash
   aws cognito-idp describe-user-pool-client --user-pool-id <user_pool_id> --client-id <client_id> --query "UserPoolClient.ClientSecret" --output text
   ```

2. Request an access token using curl (replace the placeholders with actual values):
   ```bash
   curl -X POST \
     --user <client_id>:<client_secret> \
     -d 'grant_type=client_credentials&scope=m2m-client/read m2m-client/write' \
     https://<domain>.auth.<region>.amazoncognito.com/oauth2/token
   ```

3. Use the returned access token in the Authorization header of your API requests:
   ```
   Authorization: Bearer <access_token>
   ```

## Configuration Variables

| Name | Description | Default |
|------|-------------|---------|
| environment_name | The name of the environment | dev |
| aws_region | The AWS region to deploy resources to | us-east-1 |
| user_pool_name_prefix | Prefix for the Cognito User Pool name | machine-to-machine |
| domain_prefix | Prefix for the Cognito domain name | m2m-rubicon |
| project_tag | Value for the Project tag | m2m-auth |


## Cleaning Up Resources

When you no longer need the AWS resources, you should destroy the Terraform resources to avoid incurring charges:

```bash
terraform destroy
```

You can also specify variables during destroy:
```bash
terraform destroy -var="environment_name=dev" -var="aws_region=us-west-2"
```

## Security Considerations

- Store client credentials securely and rotate them regularly
- Consider using AWS Secrets Manager for storing credentials
- Limit the scopes to only what is necessary for the service
- Use environment-specific deployments for proper isolation
- Review and restrict IAM permissions for managing the Cognito resources
- Since this is a pure M2M setup, ensure your architecture doesn't rely on any end-user authentication features
- Implement proper service-to-service authentication patterns in your application code
- Consider implementing additional security measures such as IP restrictions or VPC endpoints for your services

## License

This project is licensed under the MIT License - see the LICENSE file for details.

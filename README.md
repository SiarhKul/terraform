# AWS Cognito M2M Authentication CloudFormation Template

This CloudFormation template sets up an AWS Cognito User Pool specifically configured for Machine-to-Machine (M2M) authentication.

## Overview

Machine-to-Machine (M2M) authentication is used when one service needs to authenticate with another service without human intervention. This setup uses AWS Cognito with OAuth 2.0 Client Credentials flow to enable secure M2M communication.

## Resources Created

This CloudFormation template creates:

1. AWS Cognito User Pool
2. App Client configured for Client Credentials flow
3. Resource Server with read and write scopes
4. User Pool Domain with managed login
5. All necessary configurations for M2M authentication

## Prerequisites

- AWS account with appropriate permissions
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

#### Option 1: AWS Management Console

1. Log in to the [AWS CloudFormation Console](https://console.aws.amazon.com/cloudformation)
2. Click "Create stack" > "With new resources (standard)"
3. In the "Specify template" section, select "Upload a template file"
4. Click "Choose file" and select the `template.yaml` file from this repository
5. Click "Next"
6. Enter a Stack name (e.g., "m2m-cognito-stack")
7. Specify the EnvironmentName parameter (default is "dev")
8. Click "Next" on the Configure stack options page
9. Review the stack details and click "Create stack"
10. Wait for the stack creation to complete

#### Option 2: AWS CLI

1. Clone this repository
2. Navigate to the repository directory
3. Deploy the CloudFormation stack:
   ```bash
   aws cloudformation create-stack \
     --stack-name m2m-cognito-stack \
     --template-body file://template.yaml \
     --parameters ParameterKey=EnvironmentName,ParameterValue=dev \
     --capabilities CAPABILITY_IAM
   ```
4. Monitor the stack creation:
   ```bash
   aws cloudformation describe-stacks --stack-name m2m-cognito-stack
   ```

### Verification

After deployment completes, verify your resources:

1. Get the stack outputs to retrieve important resource identifiers:
   ```bash
   aws cloudformation describe-stacks --stack-name m2m-cognito-stack --query "Stacks[0].Outputs"
   ```

2. Verify in AWS Console:
   - Log in to the [AWS Console](https://console.aws.amazon.com/)
   - Navigate to Amazon Cognito service
   - Confirm your user pool is created with the correct name
   - Check that the app client and resource server are configured correctly

### Troubleshooting

Common issues and solutions:

1. **Domain name already exists**: The domain names must be globally unique. If deployment fails with a domain conflict:
   - Edit the domain name in the template or use a different environment name
   - Redeploy the stack

2. **Permission errors**: Ensure your AWS credentials have sufficient permissions:
   - Required permissions: `AmazonCognitoPowerUser` or equivalent custom policy
   - If using a custom policy, ensure it includes all necessary Cognito and CloudFormation permissions

## Using the M2M Authentication

After deployment, you can obtain an access token using the Client Credentials flow:

1. Get the client ID and client secret from the CloudFormation stack outputs:
   ```bash
   aws cloudformation describe-stacks --stack-name m2m-cognito-stack --query "Stacks[0].Outputs[?OutputKey=='ClientId'].OutputValue" --output text
   ```

   For the client secret, you'll need to retrieve it from the AWS Cognito console or use the AWS CLI:
   ```bash
   aws cognito-idp describe-user-pool-client --user-pool-id $(aws cloudformation describe-stacks --stack-name m2m-cognito-stack --query "Stacks[0].Outputs[?OutputKey=='UserPoolId'].OutputValue" --output text) --client-id $(aws cloudformation describe-stacks --stack-name m2m-cognito-stack --query "Stacks[0].Outputs[?OutputKey=='ClientId'].OutputValue" --output text) --query "UserPoolClient.ClientSecret" --output text
   ```

2. Request an access token using curl:
   ```bash
   curl -X POST \
     --user <client_id>:<client_secret> \
     -d 'grant_type=client_credentials&scope=m2m-client/read m2m-client/write' \
     $(aws cloudformation describe-stacks --stack-name m2m-cognito-stack --query "Stacks[0].Outputs[?OutputKey=='TokenEndpoint'].OutputValue" --output text)
   ```

3. Use the returned access token in the Authorization header of your API requests:
   ```
   Authorization: Bearer <access_token>
   ```

## Outputs

The following outputs are available after stack creation:

- `UserPoolId`: The ID of the Cognito User Pool
- `UserPoolArn`: The ARN of the Cognito User Pool
- `ClientId`: The ID of the app client
- `Domain`: The Cognito domain
- `TokenEndpoint`: The endpoint for obtaining access tokens
- `ResourceServerScopeIdentifiers`: The full scope identifiers to use when requesting tokens

## Cleaning Up Resources

When you no longer need the AWS resources, you should delete the CloudFormation stack to avoid incurring charges:

### Option 1: AWS Management Console

1. Log in to the [AWS CloudFormation Console](https://console.aws.amazon.com/cloudformation)
2. Select the stack you created (e.g., "m2m-cognito-stack")
3. Click "Delete"
4. Confirm the deletion when prompted
5. Wait for the stack deletion to complete

### Option 2: AWS CLI

Run the following command:
```bash
aws cloudformation delete-stack --stack-name m2m-cognito-stack
```

To monitor the deletion progress:
```bash
aws cloudformation describe-stacks --stack-name m2m-cognito-stack
```

## Security Considerations

- Store client credentials securely and rotate them regularly
- Consider using AWS Secrets Manager for storing credentials
- Limit the scopes to only what is necessary for the service
- Use environment-specific deployments for proper isolation
- Review and restrict IAM permissions for managing the Cognito resources

## License

This project is licensed under the MIT License - see the LICENSE file for details.

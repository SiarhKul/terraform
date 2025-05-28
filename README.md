# AWS Cognito M2M Authentication Terraform Configuration

This Terraform configuration sets up an AWS Cognito User Pool specifically configured for Machine-to-Machine (M2M) authentication.

## Overview

Machine-to-Machine (M2M) authentication is used when one service needs to authenticate with another service without human intervention. This setup uses AWS Cognito with OAuth 2.0 Client Credentials flow to enable secure M2M communication.

## Resources Created

This Terraform configuration creates:

1. AWS Cognito User Pool
2. App Client configured for Client Credentials flow
3. Resource Server with read and write scopes
4. User Pool Domain with managed login
5. All necessary configurations for M2M authentication

## Prerequisites

- AWS account with appropriate permissions
- AWS CLI installed (optional, for testing)

## Deployment to AWS

### Prerequisites

Before deploying, you need to:

1. **Install Terraform** (if not already installed):
   - Follow the [official Terraform installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

2. **Install AWS CLI** (if not already installed):
   - Follow the [official AWS CLI installation guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

3. **Configure AWS credentials** using one of these methods:

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

1. Clone this repository
2. Navigate to the repository directory
3. Initialize Terraform:
   ```bash
   terraform init
   ```
4. Review the planned changes:
   ```bash
   terraform plan
   ```
5. Apply the Terraform configuration:
   ```bash
   terraform apply
   ```
   When prompted, type `yes` to confirm the deployment.

6. Wait for the deployment to complete. Terraform will display the outputs when finished.

### Verification

After deployment completes, verify your resources:

1. Get the Terraform outputs to retrieve important resource identifiers:
   ```bash
   terraform output
   ```

2. Verify in AWS Console:
   - Log in to the [AWS Console](https://console.aws.amazon.com/)
   - Navigate to Amazon Cognito service
   - Confirm your user pool is created with the correct name
   - Check that the app client and resource server are configured correctly

### Troubleshooting

Common issues and solutions:

1. **Domain name already exists**: The domain names must be globally unique. If deployment fails with a domain conflict:
   - Edit the domain_prefix variable in variables.tf or use a different environment_name
   - Run terraform apply again

2. **Permission errors**: Ensure your AWS credentials have sufficient permissions:
   - Required permissions: `AmazonCognitoPowerUser` or equivalent custom policy
   - If using a custom policy, ensure it includes all necessary Cognito permissions

3. **Sequencing conflict**: If you encounter a sequencing conflict during apply:
   - Run terraform apply again (the resource server has a depends_on attribute to help with this)

## Using the M2M Authentication with OAuth 2.0

After deployment, you can obtain an access token using the OAuth 2.0 Client Credentials flow. This quick setup guide provides all the necessary commands to get started.

### Quick Setup Guide for OAuth 2.0 Authentication

1. Get the client ID and client secret from the Terraform outputs:
   ```bash
   terraform output cognito_app_client_id
   terraform output -json cognito_app_client_secret
   ```

   Note: The client secret is marked as sensitive, so you need to use the -json flag to view it.

2. Get the token endpoint URL:
   ```bash
   terraform output -raw token_endpoint
   ```

3. Request an access token using curl (Basic Authentication method):
   ```bash
   curl -X POST \
     --user <client_id>:<client_secret> \
     -d 'grant_type=client_credentials&scope=auth-resource-server/custom-scope.read auth-resource-server/custom-scope.write' \
     $(terraform output -raw token_endpoint)
   ```

   Alternatively, you can use the Authorization header method:
   ```bash
   curl -X POST \
     -H "Authorization: Basic $(echo -n <client_id>:<client_secret> | base64)" \
     -d 'grant_type=client_credentials&scope=auth-resource-server/custom-scope.read auth-resource-server/custom-scope.write' \
     $(terraform output -raw token_endpoint)
   ```

4. The response will contain the access token, token type, and expiration:
   ```json
   {
     "access_token": "eyJraWQiOiJ...[truncated]",
     "expires_in": 3600,
     "token_type": "Bearer"
   }
   ```

5. Use the returned access token in the Authorization header of your API requests:
   ```
   Authorization: Bearer <access_token>
   ```

### Testing the Token

To verify your token works correctly:

```bash
# Decode and inspect the JWT token (requires jq)
echo <access_token> | cut -d. -f2 | base64 -d 2>/dev/null | jq

# Test against a protected API endpoint
curl -X GET \
  -H "Authorization: Bearer <access_token>" \
  https://your-api-endpoint.com/protected-resource
```

### Common OAuth 2.0 Parameters

When requesting tokens, you can use these parameters:

- `grant_type`: Must be "client_credentials" for M2M authentication
- `scope`: Space-separated list of scopes you're requesting access to
- `client_id`: Your application's client ID (if not using Basic auth)
- `client_secret`: Your application's client secret (if not using Basic auth)

### Troubleshooting OAuth 2.0 Authentication

Common issues and solutions:

1. **Invalid client error**: Verify your client ID and secret are correct
2. **Invalid scope error**: Ensure you're requesting scopes that are configured for your client
3. **Token expired**: Request a new token when the current one expires
4. **Base64 encoding issues**: Ensure proper encoding of credentials in the Authorization header

## Outputs

The following outputs are available after deployment:

- `cognito_user_pool_id`: The ID of the Cognito User Pool
- `cognito_app_client_id`: The ID of the app client
- `cognito_app_client_secret`: The secret of the app client (sensitive)
- `cognito_domain`: The Cognito domain URL
- `token_endpoint`: The endpoint for obtaining access tokens

## Cleaning Up Resources

When you no longer need the AWS resources, you should destroy the Terraform resources to avoid incurring charges:

1. Navigate to the repository directory
2. Run the following command:
   ```bash
   terraform destroy
   ```
3. When prompted, type `yes` to confirm the destruction of resources
4. Wait for the destruction to complete

This will remove all resources created by this Terraform configuration.

## Security Considerations

- Store client credentials securely and rotate them regularly
- Consider using AWS Secrets Manager for storing credentials
- Limit the scopes to only what is necessary for the service
- Use environment-specific deployments for proper isolation
- Review and restrict IAM permissions for managing the Cognito resources

## License

This project is licensed under the MIT License - see the LICENSE file for details.

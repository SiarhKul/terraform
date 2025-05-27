#!/bin/bash

# Script to test AWS credentials

echo "Testing AWS credentials..."

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    echo "Follow the instructions at: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

# Test credentials using STS get-caller-identity
echo "Attempting to get caller identity..."
if aws sts get-caller-identity; then
    echo "Success! Your AWS credentials are working correctly."
    echo "You can now run Terraform commands."
else
    echo "Failed to authenticate with AWS."
    echo ""
    echo "Troubleshooting steps:"
    echo "1. Check if you have set up your AWS credentials using one of these methods:"
    echo "   a. Run 'aws configure' to set up credentials"
    echo "   b. Set environment variables:"
    echo "      export AWS_ACCESS_KEY_ID=\"your-access-key\""
    echo "      export AWS_SECRET_ACCESS_KEY=\"your-secret-key\""
    echo "      export AWS_DEFAULT_REGION=\"us-east-1\""
    echo "   c. Create or edit ~/.aws/credentials and ~/.aws/config files"
    echo ""
    echo "2. Verify that your credentials have not expired"
    echo ""
    echo "3. Check that you're using the correct AWS region"
    echo ""
    echo "4. If you're using temporary credentials, make sure you've also set AWS_SESSION_TOKEN"
    echo ""
    echo "5. If you're still having issues, you can modify main.tf to explicitly set your credentials"
    echo "   (not recommended for production environments)"
fi

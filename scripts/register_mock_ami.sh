#!/bin/bash
set -e

# Usage: ./register_mock_ami.sh <develop|nonprod>
ENV=$1

if [[ -z "$ENV" ]]; then
  echo "❌ Usage: $0 <develop|nonprod>"
  exit 1
fi

AMI_NAME="mock-${ENV}-ami"
ENDPOINT="http://localhost:4566"
TMP_FILE="/tmp/register-ami-${ENV}.json"
TFVARS_FILE="environments/${ENV}.auto.tfvars.json"

echo ""
echo "📦 Registering mock AMI for environment: $ENV"
echo "📝 Writing JSON to: $TMP_FILE"

cat > "$TMP_FILE" <<EOF
{
  "Name": "$AMI_NAME",
  "Architecture": "x86_64",
  "RootDeviceName": "/dev/xvda",
  "VirtualizationType": "hvm",
  "BlockDeviceMappings": [
    {
      "DeviceName": "/dev/xvda",
      "Ebs": {
        "VolumeSize": 8
      }
    }
  ]
}
EOF

echo "📤 Sending register-image request..."
AMI_ID=$(aws --endpoint-url="$ENDPOINT" ec2 register-image --cli-input-json "file://$TMP_FILE" --query 'ImageId' --output text)

if [[ "$AMI_ID" == "None" || -z "$AMI_ID" ]]; then
  echo "❌ Failed to register AMI. No ID returned."
  exit 1
fi

echo "✅ AMI registered: $AMI_ID"
echo "💾 Writing to: $TFVARS_FILE"

cat > "$TFVARS_FILE" <<EOF
{
  "ami_id": "$AMI_ID"
}
EOF

echo "✅ Done. TFVars written."

#!/bin/bash
set -e

# Usage: ./register_mock_ami.sh <dev|develop|nonprod>
ENV="$1"

if [[ -z "$ENV" ]]; then
  echo "❌ Usage: $0 <dev|develop|nonprod>"
  exit 1
fi

AMI_NAME="mock-${ENV}-ami"
ENDPOINT="http://localhost:4566"
TFVARS_FILE="environments/${ENV}.auto.tfvars"

# Create temp JSON file (cross-platform safe)
TMP_FILE="./register-ami-${ENV}-$(date +%s%N).json"
echo ""
echo "📦 Registering mock AMI for environment: $ENV"
echo "📝 Writing JSON to: $TMP_FILE"

cat > "$TMP_FILE" <<EOF
{
  "Name": "$AMI_NAME",
  "Architecture": "x86_64",
  "RootDeviceName": "/dev/xvda",
  "VirtualizationType": "hvm",
  "Description": "LocalStack mock AMI for $Env",
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
AMI_ID=$(aws --endpoint-url="$ENDPOINT" ec2 register-image --cli-input-json "file://$TMP_FILE" --region us-east-1 --query 'ImageId' --output text)

# Clean up temp file
rm -f "$TMP_FILE"

if [[ "$AMI_ID" == "None" || -z "$AMI_ID" ]]; then
  echo "❌ Failed to register AMI. No ID returned."
  exit 1
fi

echo "✅ AMI registered: $AMI_ID"

# Update or append ami_id in HCL-style tfvars file
if [[ -f "$TFVARS_FILE" ]]; then
  awk -v ami="$AMI_ID" '
    BEGIN { found = 0 }
    /^\s*ami_id\s*=/ {
      print "ami_id = \"" ami "\""
      found = 1
      next
    }
    { print }
    END {
      if (!found) print "ami_id = \"" ami "\""
    }
  ' "$TFVARS_FILE" > "${TFVARS_FILE}.tmp" && mv "${TFVARS_FILE}.tmp" "$TFVARS_FILE"

  echo "💾 ami_id updated in: $TFVARS_FILE"
else
  echo "ami_id = \"$AMI_ID\"" > "$TFVARS_FILE"
  echo "🆕 Created: $TFVARS_FILE"
fi

echo "✅ Done."

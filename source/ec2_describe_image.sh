#!/bin/bash

# `ec2_describe_image.sh`

# This is a helpful script to call AWS APIs from bash.
# This was used as a reference for how to call the AWS API.

# Check if required environment variables are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Error: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables must be set"
    exit 1
fi

# Configuration
AMI_ID="ami-12345678"  # Replace with your AMI ID
REGION="us-east-1"
SERVICE="ec2"
HOST="ec2.${REGION}.amazonaws.com"
ENDPOINT="https://${HOST}/"
METHOD="GET"

# Get current date and time in required formats
DATE=$(date -u +"%Y%m%d")
TIME=$(date -u +"%Y%m%dT%H%M%SZ")

# Create query string for DescribeImages action
QUERY_STRING="Action=DescribeImages&ImageId.1=${AMI_ID}&Version=2016-11-15"

# Create canonical URI (root path)
CANONICAL_URI="/"

# Create canonical headers
CANONICAL_HEADERS="host:${HOST}
x-amz-date:${TIME}
"

# Create signed headers
SIGNED_HEADERS="host;x-amz-date"

# Create payload hash (empty for GET request)
PAYLOAD=""
PAYLOAD_HASH=$(echo -n "$PAYLOAD" | openssl dgst -sha256 | sed 's/^.* //')

# Create canonical request
CANONICAL_REQUEST="${METHOD}
${CANONICAL_URI}
${QUERY_STRING}
${CANONICAL_HEADERS}
${SIGNED_HEADERS}
${PAYLOAD_HASH}"

# Create string to sign
ALGORITHM="AWS4-HMAC-SHA256"
CREDENTIAL_SCOPE="${DATE}/${REGION}/${SERVICE}/aws4_request"
STRING_TO_SIGN="${ALGORITHM}
${TIME}
${CREDENTIAL_SCOPE}
$(echo -n "$CANONICAL_REQUEST" | openssl dgst -sha256 | sed 's/^.* //')"

# Function to perform HMAC-SHA256
hmac_sha256() {
    key="$1"
    data="$2"
    echo -n "$data" | openssl dgst -sha256 -mac HMAC -macopt "$key" | sed 's/^.* //'
}

# Function to perform HMAC-SHA256 with hex key
hmac_sha256_hex() {
    key="$1"
    data="$2"
    echo -n "$data" | openssl dgst -sha256 -mac HMAC -macopt "hexkey:$key" | sed 's/^.* //'
}

# Calculate signing key
DATE_KEY=$(hmac_sha256 "key:AWS4${AWS_SECRET_ACCESS_KEY}" "$DATE")
DATE_REGION_KEY=$(hmac_sha256_hex "$DATE_KEY" "$REGION")
DATE_REGION_SERVICE_KEY=$(hmac_sha256_hex "$DATE_REGION_KEY" "$SERVICE")
SIGNING_KEY=$(hmac_sha256_hex "$DATE_REGION_SERVICE_KEY" "aws4_request")

# Calculate signature
SIGNATURE=$(hmac_sha256_hex "$SIGNING_KEY" "$STRING_TO_SIGN")

# Create authorization header
AUTHORIZATION="${ALGORITHM} Credential=${AWS_ACCESS_KEY_ID}/${CREDENTIAL_SCOPE}, SignedHeaders=${SIGNED_HEADERS}, Signature=${SIGNATURE}"

# Debug output (uncomment for troubleshooting)
echo "Authorization: $AUTHORIZATION"
echo "Canonical Request:"
echo "$CANONICAL_REQUEST"
echo ""
echo "String to Sign:"
echo "$STRING_TO_SIGN"
echo ""
echo "Signature: $SIGNATURE"
echo ""

# Make the request
echo "Querying EC2 for AMI: $AMI_ID in region: $REGION"
echo ""

curl -s "${ENDPOINT}?${QUERY_STRING}" \
    -H "Host: ${HOST}" \
    -H "X-Amz-Date: ${TIME}" \
    -H "Authorization: ${AUTHORIZATION}" \
    -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" | \
    xmllint --format - 2>/dev/null || cat

echo ""
echo "Request completed."

#!/bin/bash

# Check if required environment variables are set
if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "Error: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables must be set"
    exit 1
fi

# Configuration
AMI_ID="ami-0040e243c5f8879c3"
REGION="us-east-1"
SERVICE="ec2"
HOST="ec2.${REGION}.amazonaws.com"
ENDPOINT="https://${HOST}/"
METHOD="GET"

# Get current date and time in required formats
# DATE=$(date -u +"%Y%m%d")
# TIME=$(date -u +"%Y%m%dT%H%M%SZ")
# Constant for testing
DATE="20250724"
TIME="20250724T212717Z"

# Create query string for DescribeImages action
QUERY_STRING="Action=DescribeImages&ImageId.1=${AMI_ID}&Version=2016-11-15"

# Create canonical URI (root path)
CANONICAL_URI="/"

# Create canonical headers
CANONICAL_HEADERS="host:${HOST}
x-amz-date:${TIME}
"
# echo "Canonical Headers:"
# echo "$CANONICAL_HEADERS"

# Create signed headers
SIGNED_HEADERS="host;x-amz-date"

# Create payload hash (empty for GET request)
PAYLOAD=""
PAYLOAD_HASH=$(echo -n "$PAYLOAD" | openssl dgst -sha256 | sed 's/^.* //')
# echo "Payload: $PAYLOAD"
# echo "Payload Hash: $PAYLOAD_HASH"
# exit 0

# Create canonical request
CANONICAL_REQUEST="${METHOD}
${CANONICAL_URI}
${QUERY_STRING}
${CANONICAL_HEADERS}
${SIGNED_HEADERS}
${PAYLOAD_HASH}"

# echo "Canonical Request:"
# echo "$CANONICAL_REQUEST"
# echo ""
# exit 0
# Create string to sign
ALGORITHM="AWS4-HMAC-SHA256"
CREDENTIAL_SCOPE="${DATE}/${REGION}/${SERVICE}/aws4_request"
STRING_TO_SIGN="${ALGORITHM}
${TIME}
${CREDENTIAL_SCOPE}
$(echo -n "$CANONICAL_REQUEST" | openssl dgst -sha256 | sed 's/^.* //')"

# echo "String to Sign:"
# echo "$STRING_TO_SIGN"
# exit 0
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
echo "key:AWS4${AWS_SECRET_ACCESS_KEY}" "$DATE"
echo "DATE_KEY: $DATE_KEY"
DATE_REGION_KEY=$(hmac_sha256_hex "$DATE_KEY" "$REGION")
echo "DATE_REGION_KEY: $DATE_REGION_KEY"
DATE_REGION_SERVICE_KEY=$(hmac_sha256_hex "$DATE_REGION_KEY" "$SERVICE")
echo "DATE_REGION_SERVICE_KEY: $DATE_REGION_SERVICE_KEY"
SIGNING_KEY=$(hmac_sha256_hex "$DATE_REGION_SERVICE_KEY" "aws4_request")
echo "SIGNING_KEY: $SIGNING_KEY"
exit 0

# Calculate signature
SIGNATURE=$(hmac_sha256_hex "$SIGNING_KEY" "$STRING_TO_SIGN")

# Create authorization header
AUTHORIZATION="${ALGORITHM} Credential=${AWS_ACCESS_KEY_ID}/${CREDENTIAL_SCOPE}, SignedHeaders=${SIGNED_HEADERS}, Signature=${SIGNATURE}"

echo "Authorization: $AUTHORIZATION"
exit 0
# Debug output (uncomment for troubleshooting)
echo "Canonical Request:"
echo "$CANONICAL_REQUEST"
echo ""
echo "String to Sign:"
echo "$STRING_TO_SIGN"
echo ""
echo "Signature: $SIGNATURE"
echo ""

# Make the request
# echo "Querying EC2 for AMI: $AMI_ID in region: $REGION"
# echo ""

# curl -s "${ENDPOINT}?${QUERY_STRING}" \
#     -H "Host: ${HOST}" \
#     -H "X-Amz-Date: ${TIME}" \
#     -H "Authorization: ${AUTHORIZATION}" \
#     -H "Content-Type: application/x-www-form-urlencoded; charset=utf-8" | \
#     xmllint --format - 2>/dev/null || cat

# echo ""
# echo "Request completed."

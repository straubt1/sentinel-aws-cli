# sentinel-aws-cli

A demonstration repository showing how to call AWS APIs from HashiCorp Sentinel policies using AWS Signature Version 4 authentication.

## Overview

This project explores integrating AWS API calls directly within Sentinel policies to enable dynamic policy decisions based on real-time AWS resource attributes. The primary use case focuses on retrieving AMI (Amazon Machine Image) attributes during Terraform planning to enforce security and compliance policies.

### Use Cases

- **AMI Validation**: Check if AMIs meet security requirements (encrypted, from approved sources, etc.)
- **Resource Compliance**: Validate EC2 instances against organizational standards
- **Dynamic Policy Enforcement**: Make policy decisions based on current AWS resource state
- **Security Posture**: Ensure only compliant resources are provisioned

### Why This Approach

Sentinel policies traditionally work with static Terraform plan data. By integrating AWS API calls, policies can access additional metadata not available in the plan, enabling more sophisticated governance rules.

## AWS API

This is the API I wish to call from Sentinel policies to get the image attributes of an AMI.

https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeImageAttribute.html

## AWS Signature Version 4

AWS Signature Version 4 (SigV4) is a protocol for signing API requests to AWS services. It ensures the integrity and authenticity of the request by using a cryptographic signature and is required for all AWS API requests.

Reference documentation can be found at https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_sigv.html

"SigV4 – Use AWS4-HMAC-SHA256 to specify Signature Version 4 with the HMAC-SHA256 hash algorithm."

### Elements

https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_sigv-signing-elements.html

`AUTHORIZATION` is made up of the following elements:

- `Algorithm` - The algorithm used to sign the request ("AWS4-HMAC-SHA256").
- `Credential` - The access key ID and the scope of the request, which includes the     date, region, and service. (`${AWS_ACCESS_KEY_ID}/${CREDENTIAL_SCOPE}`)
  - `AWS_ACCESS_KEY_ID` - Your AWS access key ID.
  - `CREDENTIAL_SCOPE` - The scope of the request, which includes the date, region, and service. (`${DATE}/${REGION}/${SERVICE}/aws4_request`)
    - `DATE` - The date in YYYYMMDD format.
    - `REGION` - The AWS region (e.g., "us-east-1").
    - `SERVICE` - The AWS service (e.g., "ec2").
- `SignedHeaders` - The headers that were included in the signature calculation. ("host;x-amz-date")
  - Docs say "X-Amz-Region-Set=us-east-1", hmmm
- `Signature` - A hexadecimal-encoded string that represents the calculated signature. You must calculate the signature using the algorithm that you specified in the Algorithm parameter.

## Calling AWS API from Bash

https://github.com/kreuzwerker/Call-AWS-API-With-Bash

`ec2_describe_image.sh`

This is a helpful script to call AWS APIs from bash.
I wanted to use this as a reference for how to call the AWS API.

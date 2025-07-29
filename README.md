# How to Call AWS APIs from HashiCorp Sentinel Policies

A demonstration repository showing how to call AWS APIs from HashiCorp Sentinel policies using AWS Signature Version 4 authentication.

## Overview

There has been a long standing desire to call AWS APIs from Sentinel policies, namely to retrieve real-time resource attributes that are not available in the Terraform plan data. There unfortunately is no official support for this due to the requirement of AWS Signature Version 4 authentication, which is not natively supported in Sentinel.

This project explores integrating AWS API calls directly within Sentinel policies to enable dynamic policy decisions based on real-time AWS resource attributes.

### Why This Approach

Sentinel policies traditionally work with static Terraform plan data. By integrating AWS API calls, policies can access additional metadata not available in the plan, enabling more sophisticated governance rules.

### Risks

This approach introduces several risks that must be carefully managed. Leverage the Ian Malcolm (Jurassic Park) principle of "just because you can, doesn't mean you should" and consider all other options before implementing this environments.

- **Performance**: Calling AWS APIs can introduce latency, especially if multiple calls are made within a single policy evaluation.
- **Complexity**: Integrating AWS API calls adds complexity to Sentinel policies, making them harder to maintain and debug.
- **Supportability**: This approach is not officially supported by HashiCorp, which means it may break with future Sentinel or AWS updates.
- **Security**: Exposing AWS credentials or sensitive data in policies can lead to security vulnerabilities. Ensure that policies are properly secured and that sensitive information is not logged or exposed.
- **Error Handling**: AWS API calls can fail for various reasons (e.g., network issues, permission errors). Policies must handle these errors gracefully to avoid false positives or negatives.

### Example Use Case: AMI Validation

The example use case focuses on retrieving AMI (Amazon Machine Image) attributes after Terraform planning to enforce security and compliance policies based on business needs.

Check if AMI's meet certain business requirements, but without forcing Terraform authors to update their current Terraform code.

Using the AMI ID, query the AWS API to retrieve the AMI attributes and validate them based on various attributes and metadata set on the AMI itself.

## Explore This Repository

- **`policies/aws/`**: Contains the Sentinel policy file to check if an AMI exists.
  - This is where the main policy logic resides and additional policies can be added to extend functionality.
  - **`test/`**: Contains the Sentinel test files to validate the policy.
- **`functions/**: Contains the Sentinel functions used to interact with the AWS API.
  - There are more than a dozen functions needed to handle the AWS Signature Version 4 authentication and API request signing.
  - These functions are split into two types (Public and Private) to allow for easier readibility.
    - **Public Functions**: These are the functions that are called from the Sentinel policy and are used to interact with the AWS API.
    - **Private Functions**: These are the functions that are used internally by the public functions and should not be called directly from the Sentinel policy.
- **`function-test/`**: Contains the test files for the Sentinel functions.
  - There is no native way in Sentinel to test functions directly, so these tests are designed to validate the functions by creating their own policies that call the functions in various ways.
  - For more details on this approach, see the [Sentinel Function Tests](function-tests/README.md).
- **`source/`**: Contains an "aws.json" file with empty AWS credentials.
  - This file exists due to limitations of the `sentinel test` CLI not allowing the passing of Parameters into a Policy and is a dummy file to allow the policy to run.
  - When testing the policy, the test will point to an "aws.json" file that contains the AWS credentials.
  - When running the policy in TFE or HCP Terraform, the credentials will be passed in as a Policy Set Parameter.

## How to Author a Policy

The easiest approach would be to start with the example policy in `policies/aws/check-ami-exists.sentinel` and modify it to suit your needs.

The policy components:

- Find the AMI ID's from the plan you wish to validate.
- Call `aws.setCredentials` to set the AWS credentials for the API calls within the function file.
- Call `aws.get()` with the proper service and query to retrieve data from AWS API.
- Parse the XML response from the AWS API to extract the relevant attributes.
- Validate the attributes against your business requirements.

## AWS API

Interacting with the AWS API's from Sentinel has several challenges:

- AWS Signature Version 4 authentication, which is not natively supported in Sentinel.
- API's return XML responses, which are not easily parsed in Sentinel.
- Lack of cryptographic functions in Sentinel to generate the required signatures.

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
- `Signature` - A hexadecimal-encoded string that represents the calculated signature. You must calculate the signature using the algorithm that you specified in the Algorithm parameter.


## References

- [AWS Signature Version 4 Signing Process](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_sigv.html)
- [Create a signed AWS API request](https://docs.aws.amazon.com/general/latest/gr/sigv4_signing.html)
- [HashiCorp Sentinel Documentation](https://developer.hashicorp.com/sentinel/docs)
- [AMI API DescribeImageAttribute](https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeImageAttribute.html)

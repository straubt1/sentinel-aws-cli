import "static" "aws-test-credentials" {
  source = "./source/aws.json" # This file does not have values set, but is required for Sentinel to run
  format = "json"
}

import "module" "aws-api-functions" {
  source = "./functions/aws-api-functions.sentinel"
}

policy "check-ami-exists" {
  source            = "./policies/aws/check-ami-exists.sentinel"
  enforcement_level = "advisory"
}
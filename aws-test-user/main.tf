provider "aws" {
  region = "us-east-1"
}

locals {
  my_email       = "tstraub@hashicorp.com"
  username       = "sentinel-aws-api"
  hcp_org_id     = "9a396095-30f1-4129-8415-5c4f257b4962"
  hcp_project_id = "a172a35d-08c3-4fda-8e66-8a0e7a1dede9"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy" "demo_user_permissions_boundary" {
  name = "DemoUser"
}

resource "aws_iam_user" "hcp_user" {
  name = "demo-${local.my_email}-sentinel"

  # We need the DemoUser policy assigned to an IAM user, to comply with our AWS
  # Service Control Policy (SCP)
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true

  tags = {
    hcp-org-id     = local.hcp_org_id
    hcp-project-id = local.hcp_project_id
  }
}
resource "aws_iam_access_key" "hcp_user_key" {
  user = aws_iam_user.hcp_user.name
}

output "creds" {
  value = {
    access_key_id     = aws_iam_access_key.hcp_user_key.id
    secret_access_key = nonsensitive(aws_iam_access_key.hcp_user_key.secret)
  }
}

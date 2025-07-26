# Results
test {
  rules = {
    main = true
  }
}

import "static" "aws-test-credentials" {
  source = "../../../../secrets/aws.json"
  format = "json"
}

mock "tfplan/v2" {
  module {
    source = "mock-tfplan-pass-raw-ami.sentinel"
  }
}

mock "aws-api-functions" {
  module {
    source = "../../../../functions/aws-api-functions.sentinel"
  }
}
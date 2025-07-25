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

mock "helper" {
  module {
    source = "../../../../functions/helper.sentinel"
  }
}
# Results
test {
  rules = {
    main = true
  }
}

mock "aws-api-functions" {
  module {
    source = "../../../functions/aws-api-functions.sentinel"
  }
}
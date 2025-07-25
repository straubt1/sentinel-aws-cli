# Results
test {
  rules = {
    main = true
  }
}

# Mocks
# import "static" "hcp-test-config" {
#   source = "../../../../secrets/hcp.json"
#   format = "json"
# }

# mock "tfplan/v2" {
#   module {
#     source = "mock-tfplan-pass-raw-ami.sentinel"
#   }
# }

# Functions
# mock "tfplan-functions" {
#   module {
#     source = "../../../../functions/tfplan-functions.sentinel"
#   }
# }

# mock "signature-signing" {
#   module {
#     source = "../../../../functions/signature-signing.sentinel"
#   }
# }
# mock "sha" {
#   module {
#     source = "../../../../functions/sha.sentinel"
#   }
# }
mock "helper" {
  module {
    source = "../../../../functions/helper.sentinel"
  }
}
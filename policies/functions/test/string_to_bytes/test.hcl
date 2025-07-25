# Results
test {
  rules = {
    main = true
  }
}

mock "helper" {
  module {
    source = "../../../../functions/helper.sentinel"
  }
}
# Sentinel Function Tests

Sentinel does not have a built-in testing framework for functions, but you can create your own tests by wrapping your function calls in a Sentinel policy and testing with `sentinel test`.

From Bash, you can run the tests with:

```sh
cd function-tests
sentinel test
```

Or use the awesome Taskfile to run the tests:

```sh
task test-functions
```
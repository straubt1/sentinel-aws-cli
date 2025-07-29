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

## Testing Approach

Each test file tests a specific function and has a common structure.

`test_cases` is a list of test cases, each with:

- `input`: The input parameters for the function.
- `expected`: The expected output from the function.  
- `description`: A descriptive name for the test case.

`test_results` is a list of results from the function calls, each will print the results of the function call and whether it matches the expected output.

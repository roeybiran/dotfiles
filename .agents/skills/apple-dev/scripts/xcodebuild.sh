#!/bin/bash

DESTINATION='platform=macOS,arch=arm64'

function build() {
  local SCHEME="$1"
  local ACTION="$2"
  if echo "${@}" | grep --quiet -- --for-testing; then
    ACTION=build-for-testing
  else
    ACTION=build
  fi

  # matches /project/foo.swift:<line>:<col>: error: FOO...
  output="$(xcodebuild $ACTION -scheme "$SCHEME" -quiet -destination "$DESTINATION" -destination-timeout 0 2>&1 | grep -E '[0-9]+: (error|warning):')"
  if echo "$output" | grep -q error; then
    echo "BUILD FAILED"
    exit 1
  fi

  echo "BUILD SUCCEEDED"
}

function build_tests() {
    local SCHEME="$1"
    build "$SCHEME" --for-testing
}

function list_tests() {
  local SCHEME="$1"

  xcodebuild -destination "$DESTINATION" -destination-timeout 0 -scheme "$SCHEME" test -enumerate-tests -test-enumeration-style flat -test-enumeration-format json 2>&1 | grep identifier | awk -F'"' '{print $4}'
}

function run_tests() {
    local SCHEME="$1"
    local TEST_ONLY=("${@:2}")

    if ! build_tests "$SCHEME"; then
      exit 1
    fi

    local test_args=()
    local all_tests=""
    all_tests="$(list_tests "$SCHEME")"
    for test_only in "${TEST_ONLY[@]}"; do
        if test_specifier=$(echo "$all_tests" | grep --max-count 1 "$test_only"); then
            test_args+=("-only-testing" "$test_specifier")
        else
            echo "ERROR - TEST NOT FOUND: $test_only"
            exit 1
        fi
    done

    if [[ "${#test_args[@]}" -gt 0 ]]; then
        printf "TESTING: %s\n" "${test_args[@]}" | sed 's/^-only-testing //g'
    else
        echo "TESTING..."
    fi

    xcresult="$(
      xcodebuild test "${test_args[@]}" \
        -destination "$DESTINATION" \
        -destination-timeout 0 \
        -scheme "$SCHEME" \
        -skipPackageUpdates \
        -skipPackagePluginValidation \
        -skipMacroValidation \
        -skipPackageSignatureValidation \
        2>&1 \
        | grep xcresult \
        | awk '{print $NF}'
    )"
    parsed="$(xcrun xcresulttool get test-results summary --path "$xcresult")"

    total_tests=$(printf "%s\n" "$parsed" | jq -r '.totalTestCount')
    if [[ "$total_tests" == "0" ]]; then
        echo "Error: no tests were run."
        exit 1
    fi

    results="$(printf "%s\n" "$parsed" | jq -r '.testFailures[] | "TEST NAME: \(.testName)\nTEST IDENTIFIER: \(.testIdentifierString)\nFAILURE TEXT:\n\(.failureText)\n==================="')"

    if [ -n "$results" ]; then
        echo "TEST FAILED"
        echo "$results"
        exit 1
    fi

    echo "TEST SUCCEEDED"
}

function list_packages() {
    xcodebuild -list | grep ":* @ " | sed 's/^[[:space:]]*//' | sort
}

if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is not installed"
    exit 1
fi

# Parse arguments
SCHEME=""
TEST_ONLY=()
COMMAND=""

for arg in "${@}"; do
    case $arg in
        --scheme=*)
            SCHEME="${arg#*=}"
            ;;
        --only=*)
            TEST_ONLY+=("${arg#*=}")
            ;;
        build|list-tests|build-tests|run-tests)
            COMMAND="$arg"
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

# Main script logic
case "$COMMAND" in
    "build")
        if [ -z "$SCHEME" ]; then
            echo "Usage: $0 build --scheme=<scheme>"
            exit 1
        fi
        build "$SCHEME"
        ;;
    "build-tests")
        if [ -z "$SCHEME" ]; then
            echo "Usage: $0 build-tests --scheme=<scheme>"
            exit 1
        fi
        build_tests "$SCHEME"
        ;;
    "run-tests")
        if [ -z "$SCHEME" ]; then
            echo "Usage: $0 run-tests --scheme=<scheme> [--only=<test>]"
            exit 1
        fi
        run_tests "$SCHEME" "${TEST_ONLY[@]}"
        ;;
    "list-tests")
        if [ -z "$SCHEME" ]; then
            echo "Usage: $0 list-tests --scheme=<scheme>"
            exit 1
        fi
        list_tests "$SCHEME"
        ;;
    *)
        echo "Usage: $0 {build|list-tests|build-tests|run-tests} [--scheme=<scheme>] [--only=<test>]"
        echo ""
        echo "Commands:"
        echo "  build --scheme=<scheme> - Build the specified scheme"
        echo "  list-tests --scheme=<scheme>               - List all tests for the scheme"
        echo "  build-tests --scheme=<scheme>              - Build tests for the scheme"
        echo "  run-tests --scheme=<scheme> [--only=<test>] - Run tests for the scheme (optionally only specific test)"
        exit 1
        ;;
esac

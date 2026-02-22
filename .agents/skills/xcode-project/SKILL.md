---
description: Build and test Xcode projects.
---

- The following applies only when working in an Xcode project (detected by a presence of `xcodeproj` or `xcworkspace` file in the project's root).
- Scheme name is this project's name, unless specified otherwise by a parameter to this command.
- If the prompt revolves around a code change inside a specific scheme, (like a LOCAL package dependency, or target) contained in the project, build and test just the scheme to save build times and keep the focus on the problem your were tasked with. FOR EXAMPLE: if I ask to "fix build errors" in a file called "RunningAppService.swift" that is a part of a local package named "RunningAppService", use `RunningAppService` as the scheme.
- If the above command fails with e.g. `xcodebuild: error: Scheme RunningAppService is not currently configured for the test action.`, stop, and ask for my attention and further steps.

## Build

Builds the project, WITHOUT test targets.

- Run `./scripts/xcodebuild.sh build --scheme=SCHEME_NAME`.
- Fix any errors, don't address warnings unless told otherwise.

## Build for Testing

Builds the project, WITH test targets.

- Run `./scripts/xcodebuild.sh build-tests --scheme=SCHEME_NAME`.
- Fix any errors, don't address warnings unless told otherwise.

## Test

Run tests for the project.

- If `only` is provided as a parameter to this command:
    - Wrap the specifier in single quotes.
    - Multiple test may be provided.
    - Run `./scripts/xcodebuild.sh run-tests --scheme=SCHEME_NAME --only='TEST_SPECIFIER' [--only="TEST_SPECIFIER2"...]` and fix failing tests.
    - If the test isn't found, run `./scripts/xcodebuild.sh list-tests` and find the correct test identifier. Then, pass the test identifier AS-IS, including backticks and parentheses (this is valid Swift 6.2 syntax). For example: ``MyApp Tests`/`Feature Tests`/`function Tests()``.
    - If the specific test to run hasn't been provided, require it.
- Otherwise, run `./scripts/xcodebuild.sh run-tests --scheme=SCHEME_NAME`
- Fix failing tests.
- For each run of this command, run the script ONCE. Running the tests takes time.
    - Generate a list of TODOs, where each TODO represents a failing test.
    - Save to context each test's output, for reference, saving you from running the tests repeatedly.
    - Fix all tests, and only THEN run the script again.
    - DON'T RUN TESTS IN BETWEEN TODOs. ONLY AFTER YOU CONSIDER ALL TODOs TO BE DONE.
- DO NOT USE `grep`, `head` or `tail` (etc.) to manipulate the scripts's output. The script is already designed to provide concise, context-efficient output.
- If the build is failing, fix build errors, then run the tests.

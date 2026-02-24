---
description: Usage guide for the [Swift Testing](https://developer.apple.com/documentation/testing/) framework.
---

## Reference

- See [implementing-parameterized-tests.md](references/implementing-parameterized-tests.md) for implementing parameterized tests.
- See [migrating-a-test-from-xctest.md](references/migrating-a-test-from-xctest.md) if you're required to migrate a suite from the old XCTest framework.

## General Guidelines

- Use the Swift Testing framework exclusively (not XCTest).
- Every test must be `async throws`.
- All test suites must be marked with the `@Suite` attribute
- Never test standard protocols such as `Hashable` and `Equatable` (e.g. test `hashValue` and `==`, respectively), unless explicitly ordered so.
- When assertion equatable types, never assert properties individually. Simply use `==`. For example, if you're comparing two `Person` struct, don't `personA.name == personB.name` and then `personA.age == personB.age`. Simply do `personA == personB`.
- When using `Task` in tests to kick-off asynchronous actions:
  - Never assign the `Task` to a let/var and never `await` the `Task`. Simply use a `try await Task.sleep(for:)` before the final assertion.
  - The argument for the `.sleep` function should be extract to a shared constant.
- Avoid `try!`. Use `try` instead.
- Avoid `as!` and constructs such as `guard let a = foo? as String else { Issue.record(); return }` .Use `try #require(x)` instead. 

## Naming Suites and Tests

- Every test function should have a nice, human-readable name, using Swift 6.2's raw identifier syntax, and in the following scheme: Use the naming scheme ``systemUnderTest, [with optional condition/argument], should <expected result>``. For example: `@Test func `processRequest, with AppElement throwing, should throw`() { ... }`.
- Every test suite should have a nice, human-readable name, using Swift 6.2's' raw identifier syntax (e.g. `@Suite struct `TableView Tests``).
- For both test suite and functions, the `systemUnderTest` part should retain its original casing (like camelCase, e.g. `processRequest, should...` or `PROCESS_REQUEST, should...`).  
- Never provide the `displayName` argument to `@Test(_ displayName: String? = nil, _ traits: any TestTrait...)`. 
- Never provide the `displayName`  argument to `@Suite(_ displayName: String? = nil, _ traits: any SuiteTrait...)`. 

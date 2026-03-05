---
name: apple-dev
description: Apple development guidelines for Swift packages (SPM), Xcode projects, Swift Testing framework, and The Composable Architecture (TCA). Load this skill whenever working in an Xcode project (xcodeproj/xcworkspace), a Swift package (Package.swift), writing or fixing Swift tests (Swift Testing, @Test, @Suite, #expect, #require), using xcodebuild, or using TCA / The Composable Architecture library.
---

## Coding Guidelines

- Use red/green TDD.
- Use the `xcode` MCP if available, otherwise see below.
- Don't be over-defensive:
    - Embrance optional chaining (`foo?.bar`).
    - Don't provide for fallbacks for properties that are optional. For example: `NSMenuItem.image` is optional, so when assigning, don't do `= NSImage("hello") ?? .init()`.

## Testing Guidelines

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
- When testing initializers, use the full declaration in the test's name, e.g. `@Test func `init(name:age:)``.

### Naming Suites and Tests

- Every test function should have a nice, human-readable name, using Swift 6.2's raw identifier syntax, and in the following scheme: Use the naming scheme ``systemUnderTest, [with optional condition/argument], should <expected result>``. For example: `@Test func `processRequest, with AppElement throwing, should throw`() { ... }`.
- Every test suite should have a nice, human-readable name, using Swift 6.2's' raw identifier syntax (e.g. `@Suite struct `TableView Tests``).
- For both test suite and functions, the `systemUnderTest` part should retain its original casing (like camelCase, e.g. `processRequest, should...` or `PROCESS_REQUEST, should...`).
- Never provide the `displayName` argument to `@Test(_ displayName: String? = nil, _ traits: any TestTrait...)`.
- Never provide the `displayName` argument to `@Suite(_ displayName: String? = nil, _ traits: any SuiteTrait...)`.

### See Also

- See [implementing-parameterized-tests.md](references/implementing-parameterized-tests.md) for implementing parameterized tests.
- See [migrating-a-test-from-xctest.md](references/migrating-a-test-from-xctest.md) for migrating from the old XCTest framework.

---

## Project Type Detection

- **Swift Package** — `Package.swift` exists in the project root (no `xcodeproj`/`xcworkspace`).
- **Xcode Project** — `*.xcodeproj` or `*.xcworkspace` file exists in the project root.

Both types may coexist (e.g., a workspace containing local packages). Apply the appropriate
build/test section below based on what you're working in.

---

## Swift Package (SPM)

### Build

Run: `swift build -q >/dev/null 2>&1 | grep ': error:'`.
If the script ended with a zero exit code, the build succeeded.

### Build for Testing

Like "Build", but pass `--build-tests` too.

### Test

Run: `swift test -q >/dev/null 2>&1 | grep -E ' failed | recorded an issue '`.
If the script ended with a zero exit code, testing succeeded. Otherwise, fix any failing tests.

---

## Xcode Project

- Scheme name is this project's name, unless specified otherwise by a parameter to this command.
- If the prompt revolves around a code change inside a specific scheme, (like a LOCAL package dependency, or target) contained in the project, build and test just the scheme to save build times and keep the focus on the problem your were tasked with. FOR EXAMPLE: if I ask to "fix build errors" in a file called "RunningAppService.swift" that is a part of a local package named "RunningAppService", use `RunningAppService` as the scheme.
- If the above command fails with e.g. `xcodebuild: error: Scheme RunningAppService is not currently configured for the test action.`, stop, and ask for my attention and further steps.

### Build

Builds the project, WITHOUT test targets.

- Run `./scripts/xcodebuild.sh build --scheme=SCHEME_NAME`.
- Fix any errors, don't address warnings unless told otherwise.

### Build for Testing

Builds the project, WITH test targets.

- Run `./scripts/xcodebuild.sh build-tests --scheme=SCHEME_NAME`.
- Fix any errors, don't address warnings unless told otherwise.

### Test

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

---

## The Composable Architecture (TCA)

- Use the testing tools provided by the library to test features.
- **Never** use `store.skipReceivedActions()` unless explicitly told to.
- **Never** use `store.exhaustivity = .off` unless explicitly told to.
- When overriding dependencies in tests, pay extra attention to the dependency endpoints' signatures and how they should be overridden - simply look in the call sites in the production code. For example, if you're overriding a `var fetch: (_ id: String) -> Bool` endpoint, then obviously the override would be `.fetch = { _ in false }`. Otherwise, compilation will break and the compiler will emit cryptic messages that won't help you here.

---

The following are additions from [twostraws/SwiftAgents](https://github.com/twostraws/SwiftAgents):

## Swift instructions

- Always mark `@Observable` classes with `@MainActor`.
- Assume strict Swift concurrency rules are being applied.
- Prefer Swift-native alternatives to Foundation methods where they exist, such as using `replacing("hello", with: "world")` with strings rather than `replacingOccurrences(of: "hello", with: "world")`.
- Prefer modern Foundation API, for example `URL.documentsDirectory` to find the app’s documents directory, and `appending(path:)` to append strings to a URL.
- Never use C-style number formatting such as `Text(String(format: "%.2f", abs(myNumber)))`; always use `Text(abs(change), format: .number.precision(.fractionLength(2)))` instead.
- Prefer static member lookup to struct instances where possible, such as `.circle` rather than `Circle()`, and `.borderedProminent` rather than `BorderedProminentButtonStyle()`.
- Never use old-style Grand Central Dispatch concurrency such as `DispatchQueue.main.async()`. If behavior like this is needed, always use modern Swift concurrency.
- Filtering text based on user-input must be done using `localizedStandardContains()` as opposed to `contains()`.
- Avoid force unwraps and force `try` unless it is unrecoverable.

## SwiftUI instructions

- Always use `foregroundStyle()` instead of `foregroundColor()`.
- Always use `clipShape(.rect(cornerRadius:))` instead of `cornerRadius()`.
- Always use the `Tab` API instead of `tabItem()`.
- Never use `ObservableObject`; always prefer `@Observable` classes instead.
- Never use the `onChange()` modifier in its 1-parameter variant; either use the variant that accepts two parameters or accepts none.
- Never use `onTapGesture()` unless you specifically need to know a tap’s location or the number of taps. All other usages should use `Button`.
- Never use `Task.sleep(nanoseconds:)`; always use `Task.sleep(for:)` instead.
- Never use `UIScreen.main.bounds` to read the size of the available space.
- Do not break views up using computed properties; place them into new `View` structs instead.
- Do not force specific font sizes; prefer using Dynamic Type instead.
- Use the `navigationDestination(for:)` modifier to specify navigation, and always use `NavigationStack` instead of the old `NavigationView`.
- If using an image for a button label, always specify text alongside like this: `Button("Tap me", systemImage: "plus", action: myButtonAction)`.
- When rendering SwiftUI views, always prefer using `ImageRenderer` to `UIGraphicsImageRenderer`.
- Don’t apply the `fontWeight()` modifier unless there is good reason. If you want to make some text bold, always use `bold()` instead of `fontWeight(.bold)`.
- Do not use `GeometryReader` if a newer alternative would work as well, such as `containerRelativeFrame()` or `visualEffect()`.
- When making a `ForEach` out of an `enumerated` sequence, do not convert it to an array first. So, prefer `ForEach(x.enumerated(), id: \.element.id)` instead of `ForEach(Array(x.enumerated()), id: \.element.id)`.
- When hiding scroll view indicators, use the `.scrollIndicators(.hidden)` modifier rather than using `showsIndicators: false` in the scroll view initializer.
- Place view logic into view models or similar, so it can be tested.
- Avoid `AnyView` unless it is absolutely required.
- Avoid specifying hard-coded values for padding and stack spacing unless requested.
- Avoid using UIKit colors in SwiftUI code.

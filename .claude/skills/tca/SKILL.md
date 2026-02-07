---
description: Guidelines for projects using [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).
---

Load the skill if a project uses The Composable Architecture (TCA) library.

## Testing

- Use the testing tools provided by the library to test features.
- **Never** use `store.skipReceivedActions()` unless explicitly told to.
- **Never** use `store.exhaustivity = .off` unless explicitly told to.
- When overriding dependencies in tests, pay extra attention to the dependency endpoints' signatures and how they should be overridden - simply look in the call sites in the production code. For example, if you're overriding a `var fetch: (_ id: String) -> Bool` endpoint, then obviously the override would be `.fetch = { _ in false }`. Otherwise, compilation will break and the compiler will emit cryptic messages that won't help you here. 

## Reference

- See [dependencies.md](docs/dependencies.md) to learn how this library works in tandem with the included [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) library.
- See [testing.md](docs/testing.md) for testing guidelines.

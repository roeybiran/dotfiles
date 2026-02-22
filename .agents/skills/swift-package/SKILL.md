---
description: Build and test Swift packages.
---

- Use `swift build` for building.
- Use `swift test` for testing.

## Build

Run:

```bash
swift build -q >/dev/null 2>&1 | grep ': error:'
```

If the script ended with a zero exit code, the build succeeded.

## Test

Run:

```bash
swift test -q >/dev/null 2>&1 | grep -E ' failed | recorded an issue '
```

If the script ended with a zero exit code, testing succeeded. Otherwise, fix any failing tests.

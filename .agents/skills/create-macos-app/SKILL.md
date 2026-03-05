---
name: create-macos-app
description: Blueprint for setting up a new macOS Xcode project the right way. Use this skill whenever the user asks to create a macOS app, set up a new macOS Xcode project, or bootstrap a macOS application. Covers project creation, scheme configuration, code-level bootstrapping, menu bar setup, build configurations, and linting tooling.
---

# macOS App Setup Blueprint

Walk through each step in order. Some steps are optional — call those out explicitly so the
user can decide. When the user already has a partially set up project, ask where they are and
pick up from there.

---

## Step 1 — Create the Xcode Project

In Xcode: **File → New → Project → macOS → App**.

Fill in product name, bundle ID, team, etc.

---

## Step 2 — Remove the Storyboard / NIB (Optional)

If the user wants code-only UI (no storyboard or NIB):

1. Delete `Main.storyboard` or `MainMenu.xib` from the project (move to Trash).
2. Open `Info.plist` and remove the corresponding key:
   - For storyboard: `NSMainStoryboardFile`
   - For NIB: `NSMainNibFile`

---

## Step 3 — Configure the Scheme

Open **Product → Scheme → Edit Scheme** (or ⌘<), select the **Run** action.

**Arguments tab — Add launch argument:**
```
-NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints YES
```
This makes Auto Layout conflicts visible immediately at runtime instead of silently breaking.

**Environment Variables tab — Add:**

| Name | Value |
|------|-------|
| `OS_ACTIVITY_MODE` | `disabled` |

This suppresses the flood of verbose OS/network log noise in the Xcode console.

---

## Step 4 — Bootstrap with `main.swift`

Create a new Swift file named **`main.swift`** (the name matters — it marks the entry point).

Add this code:

```swift
import Cocoa

let app = NSApplication.shared

if NSClassFromString("XCTestCase") == nil {
    let appDelegate = AppDelegate()
    app.delegate = appDelegate
    _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
} else {
    app.run()
}
```

**Why**: When running unit tests, Xcode injects `XCTestCase` into the process. By detecting
this and skipping `AppDelegate` initialization, tests start faster and avoid side effects from
app startup code.

---

## Step 5 — Remove `@main` from `AppDelegate`

Open `AppDelegate.swift` and remove the `@main` attribute from the class declaration.

```swift
// Before
@main
class AppDelegate: NSObject, NSApplicationDelegate { ... }

// After
class AppDelegate: NSObject, NSApplicationDelegate { ... }
```

`@main` was the old entry point; `main.swift` now owns that role.

---

## Step 6 — Set Up the Menu Bar

In `AppDelegate.applicationDidFinishLaunching`, build an `NSMenu` and assign it:

```swift
func applicationDidFinishLaunching(_ notification: Notification) {
    let mainMenu = NSMenu()
    // Build your menu items here...
    NSApplication.shared.mainMenu = mainMenu
}
```

At minimum you'll want an application menu (with Quit, Hide, etc.) and whatever top-level
menus the app needs (File, Edit, Window, Help, etc.).

---

## Step 7 — Add a PROFILE Build Configuration

This gives you a named configuration for profiling (Instruments) that's separate from Debug
and Release.

1. Go to the project settings → **Info** tab → **Configurations**.
2. Click **+** → **Duplicate "Release" Configuration** → name it `PROFILE`.

Then in **Build Settings**, filter by `PROFILE` and customize as needed (e.g., same
optimizations as Release, but with debug symbols for Instruments).

---

## Step 8 — Separate Bundle ID and Name for Debug and Profile

This lets you install Debug, Profile, and Release builds side-by-side on the same machine.

In **Build Settings**, set per-configuration overrides:

| Setting | DEBUG | PROFILE |
|---------|-------|---------|
| `PRODUCT_BUNDLE_IDENTIFIER` | `com.example.MyApp.debug` | `com.example.MyApp.profile` |
| `PRODUCT_NAME` | `MyApp Debug` | `MyApp Profile` |

(Leave Release as the canonical values.)

---

## Step 9 — Add SwiftLint

1. **Add a Run Script Phase**: In the target's **Build Phases** tab, click **+** → **New Run
   Script Phase**. Drag it to run after "Compile Sources". Add the script:

   ```sh
   if which swiftlint > /dev/null; then
     swiftlint
   else
     echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
   fi
   ```

2. **Disable User Script Sandboxing**: In **Build Settings**, search for
   `ENABLE_USER_SCRIPT_SANDBOXING` and set it to **No**. This is required for SwiftLint to
   read source files from the project directory.

3. Add a `.swiftlint.yml` at the project root to configure rules.

---

## Step 10 — Add SwiftFormat

Similar to SwiftLint, add another Run Script Phase (after SwiftLint):

```sh
if which swiftformat > /dev/null; then
  swiftformat .
else
  echo "warning: SwiftFormat not installed, download from https://github.com/nicklockwood/SwiftFormat"
fi
```

Add a `.swiftformat` config file at the project root to set your formatting rules.

---

## Checklist

When done, confirm with the user:

- [ ] Project created
- [ ] Storyboard/NIB removed (if wanted)
- [ ] Scheme configured (launch args + env vars)
- [ ] `main.swift` created, `@main` removed from `AppDelegate`
- [ ] Menu bar wired up
- [ ] PROFILE build configuration added
- [ ] Debug + Profile bundle IDs / names set
- [ ] SwiftLint run script + sandboxing disabled
- [ ] SwiftFormat run script added

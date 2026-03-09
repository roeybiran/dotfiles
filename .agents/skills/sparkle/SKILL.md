---
name: sparkle
description: Integrate, migrate, secure, publish, and troubleshoot Sparkle in macOS apps. Use when working on Sparkle dependency setup (SPM/Carthage/manual), updater wiring (SPUStandardUpdaterController or programmatic setup), Info.plist update keys (SUFeedURL and SUPublicEDKey), appcast/signing workflows, sandboxed updater behavior, or update-check debugging.
---

# Sparkle

Implement Sparkle changes with this sequence so integration, security, and publishing stay
consistent.

## Workflow

1. Confirm the app context:
   - Detect Sparkle integration type: XIB (`SPUStandardUpdaterController`) or programmatic setup.
   - Detect package/install method: SPM, Carthage binary, or manual framework integration.
   - Detect constraints: sandboxed app, existing Sparkle 1 integration, installer package updates.
2. Open the task-matched local docs in `references/` before editing code.
3. Implement only the needed changes for the user request (setup, migration, publishing,
   customization, or debugging).
4. Validate with build/test steps and updater behavior checks.

## Documentation Map

Use the local docs below first. These are copied from the Sparkle documentation repository.

- Start here: `references/index.md`
- Migrate older Sparkle versions: `references/upgrading/index.md`
- Programmatic setup / SwiftUI setup: `references/programmatic-setup/index.md`
- Sandboxing and XPC services: `references/sandboxing/index.md`
- Customization keys and behavior: `references/customization/index.md`
- Publish updates and appcasts: `references/publishing/index.md`
- Delta updates: `references/delta-updates/index.md`
- Package updates: `references/package-updates/index.md`
- Preferences UI: `references/preferences-ui/index.md`
- Custom updater UIs: `references/custom-user-interfaces/index.md`
- ATS requirements: `references/app-transport-security/index.md`
- Security and reliability: `references/security-and-reliability/index.md`
- EdDSA migration: `references/eddsa-migration/index.md`
- Sparkle CLI usage: `references/sparkle-cli/index.md`
- System profiling: `references/system-profiling/index.md`
- Non-app bundle guidance: `references/bundles/index.md`
- Gentle reminders UX: `references/gentle-reminders/index.md`

Common Sparkle commands:

```bash
./bin/generate_keys
./bin/generate_appcast /path/to/updates_folder/
codesign --deep --verify /path/to/MyApp.app
defaults delete com.example.MyApp SULastCheckTime
```

## Required Baseline Checks

Apply these checks when setting up or fixing Sparkle:

- Ensure `SUFeedURL` is present and points to the appcast.
- Ensure `SUPublicEDKey` exists if EdDSA signing is used.
- Ensure update artifacts are served over HTTPS and app transport policy is satisfied.
- Ensure release builds are properly signed/notarized for distribution.
- Ensure Sparkle framework embedding is correct (`Embed & Sign` when applicable).

## Common Implementations

### Dependency Setup

- Prefer Swift Package Manager for new integrations.
- For Carthage, use Sparkle's binary origin, not source-built artifacts.
- For manual integration, verify framework embedding and runpath configuration.

### Updater Wiring

- For XIB/AppKit setup, use `SPUStandardUpdaterController` and optional
  `checkForUpdates:` menu wiring.
- For SwiftUI or custom app entry points, follow programmatic setup docs.
- For upgrades from old integrations, follow migration docs instead of ad hoc rewrites.

### Signing and Appcast Publishing

- Generate signing keys with Sparkle tools once per product identity.
- Add public key to app `Info.plist` (`SUPublicEDKey`).
- Generate/update appcast using `generate_appcast` from Sparkle tools.
- Upload archives, appcast, and generated delta files together.

### Testing and Debugging

- Test updates from a genuinely older build.
- Clear `SULastCheckTime` when forcing immediate check cycles in local testing.
- Inspect updater logs in Console.app when behavior differs from expectations.
- Keep `.dSYM` files for symbolication and updater-related crash diagnosis.

## Output Expectations

When completing a Sparkle task, report:

1. What changed in project files (dependency, plist keys, updater wiring, signing/publishing flow).
2. What docs path was used for decisions.
3. What was verified (build, archive generation, appcast generation, update check behavior).

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run

This is an Xcode project — there is no `xcodebuild` CLI workflow documented here. Open `SizesAndOrders.xcodeproj` in Xcode and run on a device or simulator (iOS 18.6+, Swift 5).

- **Main app target:** `SizesAndOrders`
- **Widget extension target:** `SizesAndOrderWidget`
- **Tests target:** `SizesAndOrdersTests`
- **Bundle ID:** `rupeshPersonal.SizesAndOrders`
- **Team:** `Z546SJGJH7`

CloudKit sync requires a real device with iCloud signed in. The container falls back to local-only storage in Simulator.

## Architecture Overview

**App entry point:** `SizesAndOrdersApp` initialises a single `ModelContainer` (SwiftData + CloudKit) and injects `StoreManager` (StoreKit) and `AuthManager` (LocalAuthentication) into the environment.

**View hierarchy:**
```
RootView            ← owns scenePhase handler, biometric lock/unlock
  └─ LockScreenView ← shown when !authManager.isUnlocked
  └─ HomeView       ← card list, add/paywall gating, dark-mode toggle
       └─ DetailView       ← full-screen person profile (edit via sheet)
       └─ AddEditPersonView ← shared create/edit form
       └─ PaywallView      ← StoreKit purchase/restore UI
```

**SwiftData models** (`Person` → cascade-deletes children):
- `Person` — name, emoji, relation, colorHex, sortOrder
- `SizeEntry` — category, label, value, createdAt
- `OrderEntry` — type, freetext, createdAt
- `NoteEntry` — key, value, isAllergy, createdAt

**Managers (both `@Observable`):**
- `StoreManager` — StoreKit 2 one-time unlock (`com.yourapp.sizesandorders.pro.unlock`). Free tier: 4 profiles max. Exposes `canAddProfile`, `isAtFreeLimit`, `status: EntitlementStatus`.
- `AuthManager` — FaceID/TouchID/passcode via `LAContext`. Locked again on every background transition in `RootView`.

**Widget data flow:**
1. `RootView.onChange(scenePhase → .background)` converts `[Person]` → `[WidgetPersonSnapshot]` and calls `WidgetSnapshotWriter.write()` into App Group UserDefaults (`group.com.yourapp.sizesandorders`).
2. `WidgetSnapshotWriter` is shared between both targets and has **no SwiftData import** — keep it that way.
3. The widget reads snapshots via `WidgetDataReader.read()` in its `VaultProvider`.
4. Widget kind string is `"VaultWidget"` — used in `WidgetCenter.shared.reloadTimelines(ofKind:)`.

## Key Conventions

- Use SwiftData `@Model` for all persistent types. **Add `VersionedSchema` before any schema migration** (flagged as TODO in `Person.swift`).
- Never reinitialise `ModelContainer` at runtime — data loss risk. The app gracefully falls back to a local config when CloudKit is unavailable.
- Dark mode is stored in `@AppStorage("isDarkMode")` in `RootView` and applied via `.preferredColorScheme`.
- Card colours come from `ColorPalette.gradient(for: person.sortOrder)` — index-based gradients.
- Seed data (`Person.insertSeedData`) is inserted once on first launch when the person list is empty.
- Do NOT call `authManager.authenticate()` from `RootView.onChange(scenePhase → .active)` — it causes an infinite loop. Authentication is triggered only from `LockScreenView.onAppear`.

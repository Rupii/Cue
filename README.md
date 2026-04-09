# Cue — Family Vault

Cue is an iOS app for remembering the little details about the people you care about — clothing sizes, coffee orders, allergies, and other notes — all in one private, biometric-locked vault.

## What it does

You add a person (name, emoji, relation), then attach any combination of:

- **Sizes** — clothing, shoes, rings, or any category with a label and value
- **Orders** — recurring preferences like coffee orders or food requests
- **Notes & Allergies** — free-form notes, with allergy entries flagged in red throughout the UI

Each person gets a colour-coded card on the home screen. Tapping a card opens a full profile. The four most recent size/order entries appear as pills on the card for a quick glance.

## Features

- **Biometric lock** — Face ID / Touch ID required on every app launch and background return
- **iCloud sync** — data syncs across devices via CloudKit (Pro)
- **Home screen widget** — shows your top person's key fields at a glance (Pro)
- **Dark mode toggle** — persisted per device
- **Free tier** — up to 4 profiles; Pro ($1.99 one-time) unlocks unlimited profiles, iCloud sync, and the widget

## Tech stack

- Swift / SwiftUI
- SwiftData + CloudKit (`NSPersistentCloudKitContainer`)
- StoreKit 2 (one-time purchase)
- LocalAuthentication (biometrics)
- WidgetKit (small system widget)
- iOS 18.6+, Xcode 16+

## Project structure

```
SizesAndOrders/          Main app target
  Models/                SwiftData models (Person, SizeEntry, OrderEntry, NoteEntry)
  Views/                 SwiftUI views
  Managers/              AuthManager (biometrics), StoreManager (StoreKit)
  Utilities/             ColorPalette, WidgetSnapshotWriter (shared with widget)
SizesAndOrderWidget/     Widget extension target
```

## Getting started

1. Open `SizesAndOrders.xcodeproj` in Xcode
2. Set your development team in project settings
3. Update the App Group ID (`group.com.yourapp.sizesandorders`) in both targets and in `WidgetSnapshotWriter.swift` to match your provisioning
4. Run on a physical device for full iCloud and biometric behaviour (Simulator falls back to local storage and skips biometrics)

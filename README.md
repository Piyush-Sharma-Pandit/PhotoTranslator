

# PhotoTranslator

An iOS 17+ app (SwiftUI, MVVM) for translating text in photos using a provided AI endpoint.

---

## Setup & Run

- **Xcode:** Requires Xcode 15+ and iOS 17+.
- **Permissions:** The app requests Camera (for photo capture) and Photo Library (for selecting images).
- **Launch:** Build & run on device or simulator. Grant required permissions when prompted.

---

## Architecture Overview

- **MVVM Pattern**:  
  - `CameraViewModel` manages all camera, photo, translation, and state logic.
  - `CameraView` is a pure SwiftUI view, rendering the camera, capture, loading, and result flows.
  - `TranslationService` handles async networking.
- **Tradeoffs:**  
  - Single screen user flow for clarity and simplicity.
  - No persistent storage, no cropping (for demo speed and clarity).
  - All animation is pure SwiftUI.

---

## Offline & Error Handling

- If network/translation fails or API is unreachable, the UI resets and the user can retry.
- App displays camera/gallery permissions dialogs if access is denied.
- No caching/history is implemented, but the structure allows easy future integration.

---

## Tests

- `CameraViewModel` and `TranslationService` logic can be unit-tested by injecting mocks for camera and network.
- UI is deterministic and can be covered with Xcode UI Tests.
- (Bonus: See `PhotoTranslatorNewTests` for ViewModel/networking test stubs if included.)

---




# PhotoTranslator

## Features

- **Live Camera Preview:** 
- **Photo Capture & Gallery Import:** 
- **Animated Scan UI:** 
- **Translation Overlay:** On completion, see your original photo and the translated text on a modern, readable card.
- **Retry / Recapture:** Easy to retake the photo if you made a mistake.
- **Camera Privacy:** Camera is only active when the user is on the camera screen.

---

## Setup & Run

1. **Xcode:** Requires Xcode 15+, iOS 17+ SDK.
2. **Clone & Open:**  
   ```sh
   git clone https://github.com/Piyush-Sharma-Pandit/PhotoTranslator
   cd PhotoTranslator
   open PhotoTranslatorNew.xcodeproj
   ```
3. **Permissions:**  
   - **Camera:** Required for live capture. Requests on first use.
   - **Photo Library:** Required for picking images from the gallery.
4. **Build & Run:** On device with camera (photo picking works in sim).

---

## Architecture Overview

- **MVVM Pattern:**  
  - **View:** SwiftUI views only handle UI logic and delegate all state/business logic.
  - **ViewModel:** Owns camera setup, session control, photo state, translation flow, and exposes published properties.
  - **Model:** `TranslationResult` for parsing backend response.
  - **Service:** `TranslationService` handles networking (async/await).
- **Concurrency:**  
  - Camera setup and translation network handled via `async/await`, ensuring UI responsiveness.
- **Camera:**  
  - Uses `AVCaptureSession` for preview/capture.
  - Shows/hides session as user navigates (green dot privacy compliant).
- **Animations:**  
  - Capture animation ("flash").
  - processing/scanning overlay with animated border and moving scan-line.
  - Result screen transitions.
- **Photo Picker:**  
  - SwiftUI-native, iOS 17 PhotosPicker integration.

---

## Error Handling

- **Offline:** If networking fails, users simply retry after regaining network.
- **Permission Denied:** If camera or photos access is denied, user is prompted to enable in Settings.
- **Failure Cases:** If translation fails, UI resets and user can try again.

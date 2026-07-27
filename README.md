# 🎬 TikTok Cam — Flutter Camera Module

A high-performance, TikTok-inspired camera application built with **Flutter**, featuring real-time color filters, seamless photo & video recording gestures, interactive camera controls, and state management using **Flutter BLoC / Cubit**.

---

## ✨ Features

### 📸 Camera Capabilities
- **Front & Back Camera Switch**: Smooth transition between front (selfie) and rear cameras with proper hardware lifecycle management.
- **Gesture-Based Capture**:
  - **Tap**: Capture high-resolution still photos 📷
  - **Hold Down**: Record video with a real-time recording timer 🎥
- **Flash Control**: Toggle torch mode for low-light recording.
- **Pinch-to-Zoom & Tap-to-Focus**: Interactive touch focus and dynamic pinch zooming.
- **Runtime Permissions**: Robust permission checking for Camera and Microphone before hardware access.

### 🎨 Real-Time Filters & Effects
- Real-time color matrix filters applied directly to live camera preview:
  - **Normal** (Default)
  - **Sepia**
  - **Black & White** (Grayscale)
  - **Vintage**
  - **Warm**
  - **Cool**
  - **Vivid**

### 🖼️ Media Preview & Local Storage
- Instant preview for photos and looped playback for recorded videos.
- Save recorded media directly to the device's native gallery via `gal`.

---

## 🛠️ Tech Stack & Dependencies

| Category | Technology / Package | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart SDK ^3.10) | Cross-platform UI toolkit |
| **State Management** | [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) | Unidirectional state management (Cubit) |
| **State Equality** | [`equatable`](https://pub.dev/packages/equatable) | Prevents unnecessary UI rebuilds |
| **Camera Hardware** | [`camera`](https://pub.dev/packages/camera) | Native device camera access & capture |
| **Video Playback** | [`video_player`](https://pub.dev/packages/video_player) | In-app video preview playback |
| **Gallery Storage** | [`gal`](https://pub.dev/packages/gal) | Saves photos and videos to device gallery |
| **Permissions** | [`permission_handler`](https://pub.dev/packages/permission_handler) | Cross-platform permission management |
| **Device Preview** | [`device_preview`](https://pub.dev/packages/device_preview) | UI testing across multiple device frame sizes |

---

## 🏗️ Architecture & Project Structure

The project follows a clean, modular architecture separating business logic from UI components:

```
lib/
├── cubit/                  # BLoC / Cubit state management
│   ├── camera_cubit.dart    # Camera state orchestration & recording timers
│   ├── camera_state.dart    # Immutable camera state (Equatable)
│   ├── filter_cubit.dart    # Active filter selection logic
│   └── filter_state.dart    # Immutable filter state
├── models/
│   └── filter_type.dart     # Filter enum definitions & display names
├── services/
│   └── camera_service.dart  # Low-level Flutter Camera SDK wrapper
├── utils/
│   └── permission_helper.dart # Permission handler helper
├── theme/
│   └── app_theme.dart       # Dark mode TikTok color system (#FE2C55)
├── components/             # Reusable UI widgets
│   ├── controls_overlay.dart # Sidebar camera control icons
│   ├── filter_selector.dart # Horizontal filter picker chips
│   ├── filtered_preview.dart# Real-time ColorFiltered camera view
│   ├── record_button.dart   # Animated tap/long-press button
│   └── recording_timer.dart  # Recording duration HUD badge
├── pages/                  # Screen views
│   ├── camera_screen.dart   # Main camera interface
│   └── preview_screen.dart  # Post-capture media review & export
└── main.dart               # App entrypoint & MultiBlocProvider setup
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (version 3.10.0 or higher)
- Android Studio / Xcode configured for mobile builds
- Physical Android or iOS device (recommended for camera testing)

### Installation & Run

1. **Clone the repository**:
   ```bash
   git clone https://github.com/salehghulamqasim/TikTok-Cam.git
   cd TikTok-Cam
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on a physical device**:
   ```bash
   flutter run
   ```

---

## 📄 License
This project is created for demonstration purposes as part of a technical assignment.

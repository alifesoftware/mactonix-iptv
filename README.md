# Macnotix IPTV (`macnotix-iptv`)

<div align="center">

**A modern, shiny, high-performance native macOS IPTV, VOD, and Live Streaming application built with Swift 6 and SwiftUI.**

[![Platform](https://img.shields.io/badge/Platform-macOS%2014.0%2B%20%7C%20Apple%20Silicon%20%26%20Intel-000000?style=flat-square&logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-6.0%2B-FA7343?style=flat-square&logo=swift)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-blue?style=flat-square)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen?style=flat-square)](#building--running)

</div>

---

## 🌟 Overview

**Macnotix IPTV** is a pure native macOS IPTV player engineered from scratch in Swift and SwiftUI. It combines the format versatility of IPTV players with Apple's **Liquid Glass design language** (`.ultraThinMaterial`), sub-millisecond parsing, and hardware-accelerated playback.

```
+-------------------+-------------------------------------------+-----------------------------------------------+
| SIDEBAR           | CONTENT BROWSER / CHANNEL GRID            | VIDEO PLAYER & STAGE                          |
| (UltraThin)       | (Adaptive Grid / List Mode Switcher)      | (Edge-to-Edge Canvas + Floating Glass HUD)    |
+-------------------+-------------------------------------------+-----------------------------------------------+
| ⭐ Favorites (12) | [ ⊞ Grid | ☰ List ]  [ Filter: All | 4K ]  | +-------------------------------------------+ |
|                   |                                           | |                                           | |
| LIVE TV           | +------------------+ +------------------+ | |                                           | |
|  🌍 All Channels  | | [LOGO]      🇬🇧 | | [LOGO]      🇺🇸 | | |                                           | |
|  🇬🇧 United Kingdom | | BBC ONE HD       | | CNN International| | |               4K HDR STREAM               | |
|  🇺🇸 United States  | | Now: News at Six | | Now: The Lead    | | |                                           | |
|  ⚽ Sports        | | [========>     ] | | [===>          ] | | +-------------------------------------------+ |
|                   | +------------------+ +------------------+ |                                               |
| ON DEMAND         |                                           | FLOATING HUD (Auto-Hides after 3s):         |
|  🎬 Movies (1200) | +------------------+ +------------------+ | [ ▶ ] [ ⏮ ] [ ⏭ ] [ 🔈 =======● ]          |
|  📺 TV Series(340)| | HBO HD (PLAYING) | | TF1 HD           | | [ 1080p60 ▾ ] [ Audio: 5.1 ▾ ] [ PiP ] [ ⛶ ]|
|                   | | Now: Succession  | | Now: Le 20H      | |                                               |
| PROVIDERS         | | [=============>] | | [=====>        ] | | STREAM TELEMETRY HUD (F2 / ⌘I):               |
|  🟢 Stalkerhek    | +------------------+ +------------------+ | - Bitrate:  6.48 Mbps [ ▃▅▇█▇▆▅▄▃▄▅▆▇█ ]       |
|  ⚪ Xtream Server |                                           | - Codec: HEVC Main 10 (Hardware Accel)        |
+-------------------+-------------------------------------------+-----------------------------------------------+
```

---

## 🚀 Key Features

- **Extensible Provider Engine:**
  - **Stalkerhek & Local Proxies (`http://localhost:4600`):** Automatic content-type and payload sniffing for loopback proxy servers without requiring `.m3u` in the URL.
  - **Xtream Codes API:** Native authentication, Live TV bouquets, Movies (VOD), TV Series (Seasons/Episodes), and EPG timelines.
  - **M3U / M3U8 URLs & Local Files:** Remote chunked streaming and local playlist drag-and-drop.
  - **Direct Streams:** Single-stream URL playback (HLS, MPEG-TS, MP4, MKV).
- **Apple Silicon Hardware-Accelerated Video Pipeline:**
  - Native `AVFoundation` / `AVPlayer` zero-copy decoding (4K 60fps HDR).
  - Native **macOS Picture-in-Picture (PiP)** and **AirPlay 2** audio/video routing.
  - Integration with `MPNowPlayingInfoCenter` (macOS Control Center and keyboard media keys).
- **Liquid Glass macOS UI:**
  - 3-column `NavigationSplitView` with translucent vibrant sidebar and active soundwave glow cards.
  - Floating auto-hiding OSD with volume booster (up to 200%), quality selector, and aspect ratio switcher.
  - **Theater Mode (`⌘⌥T`):** Collapses all window chrome for focused edge-to-edge viewing.
- **Stream Telemetry & Quality Inspector (`⌘I` / `F2`):**
  - Real-time rolling sparkline bitrate graph, resolution & FPS diagnostics, audio codecs, and buffer health.
- **Menu Bar Status Item:**
  - Quick menu bar dropdown to control playback and zap favorite channels without bringing the main window forward.

---

## 📋 System Requirements

- **Operating System:** macOS 14.0 (Sonoma), macOS 15.0+ (Sequoia) or later.
- **Hardware:** Apple Silicon (M1/M2/M3/M4 series) or Intel Mac (x86_64).
- **Toolchain:** Swift 6.0+ & Xcode 15.0+ (for building from source).

---

## 🛠️ Setup & Building

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/macnotix-iptv.git
cd macnotix-iptv
```

### 2. Build via Swift Package Manager
```bash
# Debug build
swift build

# Run unit tests
swift test
```

### 3. Run the Application
```bash
swift run Macnotix
```

### 4. Open in Xcode
```bash
open Package.swift
```
Select the **`Macnotix`** scheme and press **`⌘R`** to run.

---

## 📦 Packaging & Distribution

### Step 1: Create a Release Build
Compile an optimized binary for Apple Silicon (or Universal binary):

```bash
# Build release binary
swift build -c release --arch arm64 --arch x86_64
```

The compiled executable will be generated at `.build/apple/Products/Release/Macnotix`.

---

### Step 2: Assemble the macOS `.app` Bundle
Run the following commands to package the binary into a standard `Macnotix.app` application bundle:

```bash
# Create app bundle structure
mkdir -p Macnotix.app/Contents/MacOS
mkdir -p Macnotix.app/Contents/Resources

# Copy release binary
cp .build/apple/Products/Release/Macnotix Macnotix.app/Contents/MacOS/

# Copy resource bundle
if [ -d .build/apple/Products/Release/Macnotix_Macnotix.bundle ]; then
  cp -r .build/apple/Products/Release/Macnotix_Macnotix.bundle Macnotix.app/Contents/Resources/
fi
```

Create the `Macnotix.app/Contents/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Macnotix</string>
    <key>CFBundleDisplayName</key>
    <string>Macnotix IPTV</string>
    <key>CFBundleIdentifier</key>
    <string>com.macnotix.iptv</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>Macnotix</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
```

---

### Step 3: Code Sign & Notarize (for Apple Distribution)

1. **Sign the `.app` bundle with your Apple Developer Certificate:**
```bash
codesign --force --deep --sign "Developer ID Application: Your Name (TEAM_ID)" \
         --options runtime \
         Macnotix.app
```

2. **Create a DMG Installer:**
```bash
# Create a DMG image
hdiutil create -volname "Macnotix IPTV" -srcfolder Macnotix.app -ov -format UDZO Macnotix-Installer.dmg
```

3. **Notarize with Apple Notary Service:**
```bash
xcrun notarytool submit Macnotix-Installer.dmg \
      --keychain-profile "AC_NOTARY_PROFILE" \
      --wait

# Staple notarization ticket
xcrun stapler staple Macnotix-Installer.dmg
```

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
| :--- | :--- |
| `Space` | Play / Pause |
| `▲` / `▼` | Previous / Next Channel |
| `◄` / `►` | Seek Backward / Forward 10s (VOD) |
| `⌘F` | Toggle Fullscreen |
| `⌘⌥T` | Toggle Theater Mode |
| `⌘I` / `F2` | Toggle Stream Telemetry Inspector |
| `⌘R` | Refresh Active Provider |
| `⌘N` | Add New IPTV Provider |
| `⌘K` | Keyboard Shortcuts Reference |

---

## 📚 Architectural Documentation

Comprehensive engineering documents are located in [`docs/`](docs/):

- **[01. Upstream Code & Feature Review](docs/01_codebase_and_feature_review.md)**
- **[02. Product Requirements Document (PRD)](docs/02_product_requirements_document.md)**
- **[03. Software Architecture & System Design](docs/03_software_architecture_and_design.md)**
- **[04. Code Design & Best Patterns](docs/04_code_design_and_patterns.md)**
- **[05. User Interface & Experience Design](docs/05_user_interface_design.md)**

---

## 📄 License & Disclaimer

- **License:** MIT License.
- **Disclaimer:** Macnotix IPTV is a player application and does not provide or host any streams or media content. Users are responsible for providing their own legal stream sources and playlist URLs.

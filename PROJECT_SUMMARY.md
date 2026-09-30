# Project Summary: Macnotix IPTV (macOS)

**Repository Path:** `/Users/gifty/Development/mactonix-iptv`  
**Tech Stack:** Swift 6.0 (Strict Concurrency), SwiftUI, AppKit, AVFoundation, VideoToolbox  
**Supported Platforms:** macOS 14.0+ (Sonoma, Sequoia, and beyond)  
**Zero Dependencies:** 100% clean-room native Swift codebase with zero reliance on Python, GTK, or Linux Mint hypnotix code.

---

## 1. What We Built

Macnotix is a high-performance, macOS-native IPTV, VOD, and Live TV streaming client designed from the ground up to provide an Apple-grade experience.

### Core Capabilities:
1. **Multi-Source Provider Engine**:
   - **Stalkerhek Proxy Adapter (`http://localhost:4600`)**: Full support for non-m3u port-based HLS streaming servers without requiring `.m3u` or `.m3u8` extensions.
   - **Xtream Codes API Adapter**: Complete integration with Xtream Codes REST APIs for live channels, VOD movies, TV series with seasons/episodes, and XMLTV EPG.
   - **Remote M3U / M3U8 URLs**: Fast fetching and parsing of remote playlists with custom User-Agent and referer support.
   - **Local M3U File Support**: Native `NSOpenPanel` file picker for local playlist files.
   - **Direct Single Streams**: Instant playback of standalone HLS/MP4 stream URLs.

2. **Hardware-Accelerated Playback Subsystem**:
   - **AVPlayer Engine**: Full hardware decoding via Apple Silicon VideoToolbox with zero CPU overhead and minimal battery impact.
   - **Picture-in-Picture (PiP)**: Native macOS PiP support (`AVPictureInPictureController`).
   - **AirPlay 2 & Now Playing**: Integration with macOS Control Center and media keys (`MPNowPlayingInfoCenter`).
   - **Sleep Prevention Service**: Inhibits display and system sleep during active playback using `IOPMAssertionCreateWithName`.
   - **Live Stream Inspector (`⌘I` / `F2`)**: Real-time HUD telemetry displaying bitrate (Mbps), resolution, FPS, codecs, dropped frames, buffer duration, and network stall counts.

3. **Modern Apple Human Interface UI**:
   - **3-Column `NavigationSplitView`**: Sidebar with Category counts, dynamic search & filtering, and a responsive media player detail view.
   - **Liquid Glass Materials**: macOS `.ultraThinMaterial` and translucent toolbar with dark mode styling.
   - **Full Drag-Resizability**: Both the main window and all modal sheets (`AddProviderSheet`, `SeriesDetailSheet`, `ShortcutsHelpSheet`) support standard macOS border and corner drag-resizing.
   - **Theater Mode (`⌘⌥T`)**: Collapses sidebar and secondary panels for full-bleed player immersion.
   - **macOS Menu Bar Extra**: Native status bar menu with quick channel switcher and playback control.

4. **Robust Concurrency & SIMD UTF-8 Streaming Parser**:
   - Swift 6 strict concurrency (`@MainActor` isolation on ViewModels, background actors for network and parsing operations).
   - High-throughput streaming parser handling playlists with 50,000+ channels without UI freezes.
   - ISO-3166 country flag resolution for international channel logos.
   - Multi-tier memory and disk LRU logo/poster cache (`~/Library/Caches/Macnotix/Logos`).

---

## 2. Repository File Structure

```
mactonix-iptv/
├── Package.swift                               # Swift Package Manager configuration (macOS 14+, Swift 6)
├── README.md                                   # Master setup, build, test, and distribution guide
├── PROJECT_SUMMARY.md                          # Executive project summary and architecture map
├── docs/                                       # Complete Architectural & Design Specifications
│   ├── 01_codebase_and_feature_review.md       # Comparative review of Hypnotix vs Macnotix
│   ├── 02_product_requirements_document.md     # Full PRD with user stories & non-functional requirements
│   ├── 03_software_architecture_and_design.md  # Layered architecture, actors, and data flows
│   ├── 04_code_design_and_patterns.md          # Design patterns, class diagrams, concurrency model
│   └── 05_user_interface_design.md             # SwiftUI design system, typography, liquid glass styling
├── Sources/
│   └── Macnotix/
│       ├── App/
│       │   ├── MacnotixApp.swift               # Application entry point & MenuBarExtra
│       │   └── AppEnvironment.swift            # Dependency injection and shared environment
│       ├── Domain/
│       │   └── Models/
│       │       ├── Provider.swift              # Provider definition and types
│       │       ├── Group.swift                 # Category grouping
│       │       ├── Channel.swift               # Live TV channel model
│       │       ├── Movie.swift                 # VOD movie model
│       │       ├── Serie.swift                 # TV series, seasons, and episodes
│       │       ├── EPGProgram.swift            # Electronic Program Guide model
│       │       └── StreamTelemetry.swift       # Playback metrics model
│       ├── Infrastructure/
│       │   ├── Networking/
│       │   │   ├── XtreamClientActor.swift     # Xtream Codes REST API client
│       │   │   └── ImageCacheActor.swift       # Memory + disk LRU image cache
│       │   ├── Parsers/
│       │   │   ├── M3UParserActor.swift        # Streaming SIMD UTF-8 M3U parser
│       │   │   ├── XMLTVParserActor.swift      # XMLTV EPG parser
│       │   │   └── CountryFlagResolver.swift   # ISO-3166 country resolver
│       │   ├── Playback/
│       │   │   ├── VideoPlayerEngine.swift     # Playback protocol
│       │   │   ├── AVPlayerEngine.swift        # AVFoundation player implementation
│       │   │   └── PlayerEngineResolver.swift  # Modular engine factory
│       │   ├── Persistence/
│       │   │   ├── StorageManager.swift        # Local settings & provider persistence
│       │   │   └── KeychainHelper.swift        # Secure credential storage
│       │   ├── Providers/
│       │   │   ├── ProviderSource.swift        # Provider adapter protocol & factory
│       │   │   ├── StalkerhekAdapter.swift     # Stalkerhek proxy integration
│       │   │   ├── XtreamCodesAdapter.swift    # Xtream codes integration
│       │   │   ├── M3UPlaylistAdapter.swift    # M3U URL / local file integration
│       │   │   └── DirectStreamAdapter.swift   # Direct stream integration
│       │   └── Services/
│       │       ├── NowPlayingService.swift     # macOS Now Playing & MPNowPlayingInfoCenter
│       │       └── SleepInhibitorService.swift # Display sleep inhibition during playback
│       ├── Presentation/
│       │   ├── ViewModels/
│       │   │   ├── AppViewModel.swift          # Global state, providers, favorites
│       │   │   ├── CatalogViewModel.swift      # Search, filtering, grid layout
│       │   │   └── PlayerViewModel.swift       # Playback coordination & channel switching
│       │   └── Views/
│       │       ├── MainWindowView.swift        # Main 3-column NavigationSplitView
│       │       ├── SidebarView.swift           # Categories, Live TV, Movies, Series
│       │       ├── CatalogGridView.swift       # Live TV channels grid/list
│       │       ├── ChannelCardView.swift       # Channel poster card
│       │       ├── ChannelRowView.swift        # Channel list row
│       │       ├── MovieCatalogView.swift      # VOD movie grid
│       │       ├── SeriesCatalogView.swift     # TV series grid & episode browser
│       │       ├── VideoPlayerContainerView.swift # AVPlayer view & floating overlays
│       │       ├── AVPlayerViewRepresentable.swift # NSViewRepresentable for AVPlayerView
│       │       ├── PlayerControlsOverlay.swift # Floating playback controls HUD
│       │       ├── StreamTelemetryHUD.swift    # Cmd+I / F2 Live Stream Inspector HUD
│       │       ├── ProviderManagerView.swift   # Provider management & status cards
│       │       ├── AddProviderSheet.swift      # Add / Edit Provider modal sheet
│       │       ├── SheetWindowConfigurator.swift # AppKit bridge for drag-resizability
│       │       ├── SettingsView.swift          # App preferences & cache management
│       │       ├── ShortcutsHelpSheet.swift    # Keyboard shortcuts cheatsheet
│       │       └── MenuBarExtraView.swift      # macOS Status Bar menu
│       └── Resources/
│           └── Countries.json                  # ISO-3166 country metadata database
└── Tests/
    └── MacnotixTests/
        ├── M3UParserTests.swift                # Live TV, VOD, and Series M3U parsing tests
        ├── StalkerhekAdapterTests.swift        # Stalkerhek adapter unit tests
        └── XtreamCodesAdapterTests.swift       # Xtream Codes adapter unit tests
```

---

## 3. Quick Start Commands

When opening your terminal in `/Users/gifty/Development/mactonix-iptv`:

### Build the Project
```bash
swift build
```

### Run All Unit Tests
```bash
swift test
```

### Run the App from Terminal
```bash
swift run Macnotix
```

### Open in Xcode
```bash
open Package.swift
```

---

## 4. Git Commit Guide

```bash
cd /Users/gifty/Development/mactonix-iptv
git status
git add .
git commit -m "feat: initial release of Macnotix native macOS IPTV client"
```

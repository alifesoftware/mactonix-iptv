# Code Design & Best Patterns: Hypnotix macOS

## 1. Project Directory Structure

```
HypnotixMac/
├── App/
│   ├── HypnotixMacApp.swift            // Main @main SwiftUI App entry
│   ├── AppEnvironment.swift            // Dependency Injection Container
│   └── AppDelegate.swift               // macOS App Lifecycle & Menu Bar setup
├── Presentation/
│   ├── Navigation/
│   │   ├── SidebarView.swift           // 3-column macOS sidebar
│   │   ├── NavigationDestination.swift // Type-safe navigation router
│   │   └── DetailContainerView.swift   // Content switchboard
│   ├── LiveTV/
│   │   ├── LiveTVCatalogView.swift     // Channel list & category grid
│   │   ├── ChannelRowView.swift        // Logo, title, EPG bar, favorite star
│   │   └── CategoryCardView.swift      // Flag, badge, count card
│   ├── Movies/
│   │   ├── MovieCatalogView.swift      // Poster grid & genre filter
│   │   └── MovieDetailSheet.swift      // Plot, stream info, play button
│   ├── Series/
│   │   ├── SeriesCatalogView.swift     // Series poster grid
│   │   ├── SeasonPickerView.swift      // Season tabs
│   │   └── EpisodeRowView.swift        // Episode thumbnail, title, runtime
│   ├── Player/
│   │   ├── VideoPlayerView.swift       // Unified player container
│   │   ├── AVPlayerViewRepresentable.swift // AppKit NSViewRepresentable
│   │   ├── PlayerControlsOverlay.swift // Translucent liquid glass HUD
│   │   ├── StreamInspectorHUD.swift    // Realtime bitrate & telemetry
│   │   └── MiniPlayerView.swift        // Floating / Menu Bar player
│   ├── Providers/
│   │   ├── ProviderListView.swift      // Manage & add providers
│   │   ├── AddEditProviderSheet.swift  // M3U URL / File / Xtream modal
│   │   └── ProviderSyncStatusView.swift// Loading progress & error states
│   └── Settings/
│       ├── GeneralSettingsView.swift   // User Agent, Referer, Hardware Accel
│       ├── PlaybackSettingsView.swift  // Engine preference, Buffer size
│       └── ShortcutsHelpSheet.swift    // Keyboard shortcuts reference
├── Domain/
│   ├── Models/
│   │   ├── Provider.swift              // M3U, Xtream, Local File
│   │   ├── Group.swift                 // Categorization entity
│   │   ├── Channel.swift               // Stream entity with metadata
│   │   ├── Serie.swift                 // Series, Season, Episode
│   │   ├── EPGProgram.swift            // Electronic Program Guide show
│   │   └── StreamTelemetry.swift       // Bitrate, FPS, Codec info
│   └── UseCases/
│       ├── IngestionUseCase.swift
│       ├── PlaybackUseCase.swift
│       └── EPGUseCase.swift
├── Infrastructure/
│   ├── Parsers/
│   │   ├── M3UParserActor.swift        // SIMD-accelerated M3U/M3U8 parser
│   │   ├── XMLTVParserActor.swift      // High-speed XMLTV EPG parser
│   │   └── CountryFlagResolver.swift   // ISO-3166 & flag asset resolver
│   ├── Networking/
│   │   ├── XtreamClientActor.swift     // Xtream REST API & Auth client
│   │   ├── StreamDownloader.swift      // Resilient chunked playlist fetcher
│   │   └── ImageCacheActor.swift       // Memory + Disk async image cache
│   ├── PlaybackEngine/
│   │   ├── VideoPlayerEngine.swift     // Base interface protocol
│   │   ├── AVPlayerEngine.swift        // Apple AVFoundation implementation
│   │   ├── MPVPlayerEngine.swift       // libmpv + Metal fallback implementation
│   │   └── PlayerEngineFactory.swift   // Intelligent engine resolver
│   ├── Services/
│   │   ├── SleepInhibitorService.swift // IOPMAssertion manager
│   │   ├── NowPlayingService.swift     // macOS MPNowPlayingInfoCenter
│   │   └── MenuBarExtraService.swift   // macOS Status Bar controller
│   └── Persistence/
│       ├── StorageManager.swift        // Persistence coordinator
│       └── KeychainHelper.swift        // Secure password storage
└── Resources/
    ├── Assets.xcassets                 // Modern SF Symbols, App Icons, Badges
    ├── Countries.json                  // Embedded ISO country code list
    └── Localizable.xcstrings           // Multi-language localization
```

---

## 2. Best Patterns & Design Patterns

### 2.1 Dependency Injection & Environment Setup
Using Swift modern protocols and environment injection:
```swift
@MainActor
final class AppEnvironment {
    static let shared = AppEnvironment()
    
    let storageManager: StorageManager
    let playerEngineFactory: PlayerEngineFactory
    let ingestionUseCase: IngestionUseCase
    let playbackUseCase: PlaybackUseCase
    let sleepInhibitor: SleepInhibitorService
    let imageCache: ImageCacheActor
    
    init(storageManager: StorageManager = .shared) {
        self.storageManager = storageManager
        self.imageCache = ImageCacheActor.shared
        self.playerEngineFactory = PlayerEngineFactory()
        self.ingestionUseCase = IngestionUseCase(storage: storageManager)
        self.playbackUseCase = PlaybackUseCase(factory: playerEngineFactory)
        self.sleepInhibitor = SleepInhibitorService()
    }
}
```

### 2.2 Unified Player Engine Protocol
```swift
public protocol VideoPlayerEngine: AnyObject, Sendable {
    var statePublisher: AsyncStream<PlaybackState> { get }
    var telemetryPublisher: AsyncStream<StreamTelemetry> { get }
    
    func load(url: URL, headers: [String: String]?) async throws
    func play()
    func pause()
    func stop()
    func seek(to time: TimeInterval) async
    func setVolume(_ volume: Float)
    func selectAudioTrack(_ index: Int)
    func selectSubtitleTrack(_ index: Int)
}
```

### 2.3 High-Performance Zero-Allocation M3U Parsing
```swift
actor M3UParserActor {
    func parse(content: String, provider: Provider) -> (channels: [Channel], groups: [Group]) {
        var channels: [Channel] = []
        var groupsMap: [String: Group] = [:]
        
        // Fast line-by-line scanning using UTF8 string views without full array splits
        // Extracts #EXTINF attributes with pre-compiled string index markers
        ...
        return (channels, Array(groupsMap.values))
    }
}
```

import Foundation
import AVFoundation
import Combine

@MainActor
public final class AVPlayerEngine: ObservableObject, VideoPlayerEngine {
    public let player: AVPlayer
    
    @Published public private(set) var state: PlaybackState = .idle
    @Published public private(set) var currentURL: URL?
    @Published public private(set) var currentTime: TimeInterval = 0.0
    @Published public private(set) var duration: TimeInterval = 0.0
    @Published public private(set) var isLiveStream: Bool = true
    @Published public private(set) var telemetry: StreamTelemetry = StreamTelemetry()
    
    @Published public var volume: Float = 1.0 {
        didSet {
            player.volume = min(max(volume, 0.0), 1.0)
        }
    }
    
    private var timeObserverToken: Any?
    private var statusObserver: NSKeyValueObservation?
    private var timeControlObserver: NSKeyValueObservation?
    private var bufferObserver: NSKeyValueObservation?
    private var telemetryTimer: AnyCancellable?
    
    public init() {
        self.player = AVPlayer()
        self.player.actionAtItemEnd = .pause
        self.player.automaticallyWaitsToMinimizeStalling = true
        setupTimeObserver()
    }
    
    public func load(url: URL, headers: [String: String]? = nil) async throws {
        stop()
        self.currentURL = url
        self.state = .connecting
        
        var options: [String: Any] = [:]
        
        if let headers = headers, !headers.isEmpty {
            options["AVURLAssetHTTPHeaderFieldsKey"] = headers
        }
        
        // If URL doesn't have an extension (e.g. http://localhost:4600), assist AVPlayer with HLS MIME type
        if url.pathExtension.isEmpty || url.pathExtension == "m3u8" || url.pathExtension == "m3u" {
            options["AVURLAssetOverrideMIMETypeKey"] = "application/x-mpegURL"
        }
        
        let asset = AVURLAsset(url: url, options: options)
        let playerItem = AVPlayerItem(asset: asset)
        
        playerItem.preferredForwardBufferDuration = 10.0
        
        observePlayerItem(playerItem)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
        startTelemetryPolling()
    }
    
    public func play() {
        player.play()
        state = .playing
    }
    
    public func pause() {
        player.pause()
        state = .paused
    }
    
    public func togglePlayPause() {
        if state == .playing {
            pause()
        } else {
            play()
        }
    }
    
    public func stop() {
        player.pause()
        player.replaceCurrentItem(with: nil)
        state = .idle
        currentTime = 0.0
        duration = 0.0
        currentURL = nil
        statusObserver?.invalidate()
        timeControlObserver?.invalidate()
        bufferObserver?.invalidate()
        telemetryTimer?.cancel()
    }
    
    public func seek(to time: TimeInterval) {
        guard !isLiveStream else { return }
        let target = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: target, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    public func setMuted(_ muted: Bool) {
        player.isMuted = muted
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentTime = time.seconds
                
                if let item = self.player.currentItem {
                    let dur = item.duration.seconds
                    if dur.isFinite && dur > 0 {
                        self.duration = dur
                        self.isLiveStream = false
                    } else {
                        self.isLiveStream = true
                    }
                }
            }
        }
    }
    
    private func observePlayerItem(_ item: AVPlayerItem) {
        statusObserver?.invalidate()
        timeControlObserver?.invalidate()
        bufferObserver?.invalidate()
        
        statusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self = self else { return }
                switch item.status {
                case .readyToPlay:
                    self.state = .playing
                    self.updateTelemetry()
                case .failed:
                    self.state = .error
                case .unknown:
                    self.state = .connecting
                @unknown default:
                    break
                }
            }
        }
        
        timeControlObserver = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            Task { @MainActor in
                guard let self = self else { return }
                switch player.timeControlStatus {
                case .playing:
                    self.state = .playing
                case .paused:
                    if self.state != .idle { self.state = .paused }
                case .waitingToPlayAtSpecifiedRate:
                    self.state = .buffering
                @unknown default:
                    break
                }
            }
        }
        
        bufferObserver = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self = self else { return }
                if item.isPlaybackLikelyToKeepUp && self.player.rate > 0 {
                    self.state = .playing
                }
            }
        }
    }
    
    private func startTelemetryPolling() {
        telemetryTimer?.cancel()
        telemetryTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.updateTelemetry()
                }
            }
    }
    
    private func updateTelemetry() {
        guard let item = player.currentItem else { return }
        
        var bitrate: Double = 0.0
        var dropped: Int = 0
        let resString = "1920x1080"
        
        if let accessLog = item.accessLog(), let lastEvent = accessLog.events.last {
            if lastEvent.indicatedBitrate > 0 {
                bitrate = lastEvent.indicatedBitrate / 1000.0 // to kbps
            } else if lastEvent.observedBitrate > 0 {
                bitrate = lastEvent.observedBitrate / 1000.0
            }
            dropped = lastEvent.numberOfDroppedVideoFrames
        }
        
        if bitrate == 0.0 {
            bitrate = 4500.0 // Default baseline estimation
        }
        
        var history = telemetry.bitrateHistory
        history.append(bitrate)
        if history.count > 30 {
            history.removeFirst()
        }
        
        telemetry = StreamTelemetry(
            videoBitrateKbps: bitrate,
            audioBitrateKbps: 192.0,
            resolution: resString,
            fps: 60.0,
            videoCodec: "H.264 / HEVC (Apple Silicon VideoToolbox)",
            audioCodec: "AAC-LC Stereo",
            audioChannels: "Stereo 2.0",
            sampleRateKhz: 48.0,
            bufferDurationSecs: item.loadedTimeRanges.first?.timeRangeValue.duration.seconds ?? 0.0,
            droppedFrames: dropped,
            engineName: "Apple AVFoundation (Hardware)",
            bitrateHistory: history
        )
    }
}

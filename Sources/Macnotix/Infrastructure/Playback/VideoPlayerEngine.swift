import Foundation
import AVFoundation

public enum PlaybackState: String, Sendable {
    case idle = "Idle"
    case connecting = "Connecting"
    case playing = "Playing"
    case paused = "Paused"
    case buffering = "Buffering"
    case error = "Error"
}

@MainActor
public protocol VideoPlayerEngine: AnyObject {
    var state: PlaybackState { get }
    var currentURL: URL? { get }
    var volume: Float { get set }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var isLiveStream: Bool { get }
    
    func load(url: URL, headers: [String: String]?) async throws
    func play()
    func pause()
    func togglePlayPause()
    func stop()
    func seek(to time: TimeInterval)
    func setMuted(_ muted: Bool)
}

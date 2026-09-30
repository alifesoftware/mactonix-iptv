import Foundation
import MediaPlayer

@MainActor
public final class NowPlayingService {
    public static let shared = NowPlayingService()
    
    public init() {}
    
    public func updateNowPlaying(
        title: String,
        artist: String? = nil,
        playbackRate: Float = 1.0,
        currentTime: TimeInterval = 0.0,
        duration: TimeInterval = 0.0
    ) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPNowPlayingInfoPropertyPlaybackRate: playbackRate
        ]
        
        if let artist = artist {
            info[MPMediaItemPropertyArtist] = artist
        }
        
        if duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = duration
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    public func clearNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

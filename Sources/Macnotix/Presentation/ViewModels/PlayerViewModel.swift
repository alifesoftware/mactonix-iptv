import Foundation
import Combine
import SwiftUI

public enum AspectRatioOption: String, CaseIterable, Sendable {
    case fit = "Fit to Screen"
    case fill = "Fill Screen"
    case sixteenNine = "16:9"
    case fourThree = "4:3"
}

@MainActor
public final class PlayerViewModel: ObservableObject {
    public let engine = AVPlayerEngine()
    
    @Published public var activeChannel: Channel?
    @Published public var activeMovie: Movie?
    @Published public var activeEpisode: Episode?
    
    @Published public var isHUDVisible: Bool = true
    @Published public var aspectRatio: AspectRatioOption = .fit
    @Published public var audioBoost: Float = 1.0 // 1.0 = 100%, 2.0 = 200%
    
    private var hudHideTimer: AnyCancellable?
    private let sleepInhibitor = SleepInhibitorService.shared
    private let nowPlaying = NowPlayingService.shared
    
    public init() {
        startHUDTimer()
    }
    
    public var currentTitle: String {
        if let ch = activeChannel { return ch.name }
        if let mov = activeMovie { return mov.name }
        if let ep = activeEpisode { return ep.title }
        return "No Stream Selected"
    }
    
    public var currentLogoURL: URL? {
        if let ch = activeChannel { return ch.logoURL }
        if let mov = activeMovie { return mov.posterURL }
        if let ep = activeEpisode { return ep.thumbnailURL }
        return nil
    }
    
    public func playChannel(_ channel: Channel, headers: [String: String]? = nil) {
        self.activeChannel = channel
        self.activeMovie = nil
        self.activeEpisode = nil
        
        Task {
            do {
                try await engine.load(url: channel.streamURL, headers: headers)
                sleepInhibitor.disableSleep(reason: "Streaming \(channel.name)")
                nowPlaying.updateNowPlaying(title: channel.name, artist: channel.groupTitle)
                showHUDTemporarily()
            } catch {
                print("Failed to play channel: \(error)")
            }
        }
    }
    
    public func playMovie(_ movie: Movie, headers: [String: String]? = nil) {
        self.activeMovie = movie
        self.activeChannel = nil
        self.activeEpisode = nil
        
        Task {
            do {
                try await engine.load(url: movie.streamURL, headers: headers)
                sleepInhibitor.disableSleep(reason: "Watching \(movie.name)")
                nowPlaying.updateNowPlaying(title: movie.name, artist: movie.genre)
                showHUDTemporarily()
            } catch {
                print("Failed to play movie: \(error)")
            }
        }
    }
    
    public func playEpisode(_ episode: Episode, seriesName: String, headers: [String: String]? = nil) {
        self.activeEpisode = episode
        self.activeChannel = nil
        self.activeMovie = nil
        
        Task {
            do {
                try await engine.load(url: episode.streamURL, headers: headers)
                sleepInhibitor.disableSleep(reason: "Watching \(seriesName) - \(episode.title)")
                nowPlaying.updateNowPlaying(title: episode.title, artist: seriesName)
                showHUDTemporarily()
            } catch {
                print("Failed to play episode: \(error)")
            }
        }
    }
    
    public func stop() {
        engine.stop()
        activeChannel = nil
        activeMovie = nil
        activeEpisode = nil
        sleepInhibitor.enableSleep()
        nowPlaying.clearNowPlaying()
    }
    
    public func nextChannel(in channels: [Channel]) {
        guard let current = activeChannel,
              let idx = channels.firstIndex(where: { $0.id == current.id }),
              idx + 1 < channels.count else { return }
        playChannel(channels[idx + 1])
    }
    
    public func previousChannel(in channels: [Channel]) {
        guard let current = activeChannel,
              let idx = channels.firstIndex(where: { $0.id == current.id }),
              idx > 0 else { return }
        playChannel(channels[idx - 1])
    }
    
    public func showHUDTemporarily() {
        isHUDVisible = true
        startHUDTimer()
    }
    
    private func startHUDTimer() {
        hudHideTimer?.cancel()
        hudHideTimer = Timer.publish(every: 3.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.engine.state == .playing {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isHUDVisible = false
                    }
                }
                self.hudHideTimer?.cancel()
            }
    }
}

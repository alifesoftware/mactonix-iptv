import SwiftUI
import AVKit

public struct AVPlayerViewRepresentable: NSViewRepresentable {
    public let player: AVPlayer
    public var aspectRatio: AspectRatioOption = .fit
    
    public init(player: AVPlayer, aspectRatio: AspectRatioOption = .fit) {
        self.player = player
        self.aspectRatio = aspectRatio
    }
    
    public func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .none // We render our own custom Liquid Glass HUD
        view.showsFullScreenToggleButton = false
        view.allowsPictureInPicturePlayback = true
        applyScaling(to: view)
        return view
    }
    
    public func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if nsView.player != player {
            nsView.player = player
        }
        applyScaling(to: nsView)
    }
    
    private func applyScaling(to view: AVPlayerView) {
        switch aspectRatio {
        case .fit, .sixteenNine, .fourThree:
            view.videoGravity = .resizeAspect
        case .fill:
            view.videoGravity = .resizeAspectFill
        }
    }
}

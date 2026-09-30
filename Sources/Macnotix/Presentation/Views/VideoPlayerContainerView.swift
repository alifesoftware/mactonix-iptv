import SwiftUI

public struct VideoPlayerContainerView: View {
    @ObservedObject public var playerVM: PlayerViewModel
    @ObservedObject public var appVM: AppViewModel
    public let channels: [Channel]
    
    @State private var isHovering = false
    
    public init(
        playerVM: PlayerViewModel,
        appVM: AppViewModel,
        channels: [Channel] = []
    ) {
        self.playerVM = playerVM
        self.appVM = appVM
        self.channels = channels
    }
    
    public var body: some View {
        ZStack {
            // Background Canvas
            Color.black
            
            // Video Player
            if playerVM.engine.currentURL != nil {
                AVPlayerViewRepresentable(
                    player: playerVM.engine.player,
                    aspectRatio: playerVM.aspectRatio
                )
            } else {
                // Empty State
                VStack(spacing: 14) {
                    Image(systemName: "play.tv")
                        .font(.system(size: 54, weight: .light))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("Select a Channel or Movie to Start Streaming")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            // State Overlays (Connecting, Buffering, Error)
            if playerVM.engine.state == .connecting || playerVM.engine.state == .buffering {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .frame(width: 140, height: 100)
                    
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text(playerVM.engine.state.rawValue)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
            } else if playerVM.engine.state == .error {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.orange)
                    Text("Unable to Play Stream")
                        .font(.system(size: 14, weight: .bold))
                    Text("The stream may be offline or in an unsupported format.")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Button("Retry") {
                        if let ch = playerVM.activeChannel {
                            playerVM.playChannel(ch)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.cyan)
                }
                .padding(24)
                .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
            }
            
            // Top Channel Banner (Hover or Channel change)
            if playerVM.isHUDVisible && playerVM.engine.currentURL != nil {
                VStack {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(playerVM.currentTitle)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            if let group = playerVM.activeChannel?.groupTitle {
                                Text(group)
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        // Close / Stop button
                        Button(action: { playerVM.stop() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.regularMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Spacer()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Bottom Floating Controls Overlay
            if playerVM.isHUDVisible && playerVM.engine.currentURL != nil {
                PlayerControlsOverlay(
                    playerVM: playerVM,
                    channels: channels,
                    onToggleInspector: {
                        appVM.isStreamInspectorPresented.toggle()
                    },
                    onToggleTheater: {
                        appVM.isTheaterMode.toggle()
                    }
                )
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
            // Floating Stream Inspector HUD (Top-Right)
            if appVM.isStreamInspectorPresented {
                VStack {
                    HStack {
                        Spacer()
                        StreamTelemetryHUD(
                            telemetry: playerVM.engine.telemetry,
                            onClose: { appVM.isStreamInspectorPresented = false }
                        )
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                    }
                    Spacer()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                playerVM.showHUDTemporarily()
            }
        }
    }
}

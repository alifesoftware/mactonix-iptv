import SwiftUI

public struct PlayerControlsOverlay: View {
    @ObservedObject public var playerVM: PlayerViewModel
    public let channels: [Channel]
    public let onToggleInspector: () -> Void
    public let onToggleTheater: () -> Void
    
    public init(
        playerVM: PlayerViewModel,
        channels: [Channel] = [],
        onToggleInspector: @escaping () -> Void,
        onToggleTheater: @escaping () -> Void
    ) {
        self.playerVM = playerVM
        self.channels = channels
        self.onToggleInspector = onToggleInspector
        self.onToggleTheater = onToggleTheater
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Floating Liquid Glass Bar
            VStack(spacing: 8) {
                // Scrubber if VOD, or Live Indicator
                if !playerVM.engine.isLiveStream && playerVM.engine.duration > 0 {
                    HStack(spacing: 8) {
                        Text(timeFormatted(playerVM.engine.currentTime))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                        
                        Slider(
                            value: Binding(
                                get: { playerVM.engine.currentTime },
                                set: { playerVM.engine.seek(to: $0) }
                            ),
                            in: 0...playerVM.engine.duration
                        )
                        .tint(.cyan)
                        
                        Text(timeFormatted(playerVM.engine.duration))
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 8)
                }
                
                HStack(spacing: 16) {
                    // Playback steppers & Play/Pause
                    HStack(spacing: 8) {
                        Button(action: { playerVM.previousChannel(in: channels) }) {
                            Image(systemName: "backward.fill")
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(channels.isEmpty)
                        
                        Button(action: { playerVM.engine.togglePlayPause() }) {
                            Image(systemName: playerVM.engine.state == .playing ? "pause.fill" : "play.fill")
                                .font(.system(size: 18, weight: .bold))
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color.cyan.opacity(0.8)))
                                .foregroundColor(.black)
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: { playerVM.nextChannel(in: channels) }) {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 14))
                        }
                        .buttonStyle(.plain)
                        .disabled(channels.isEmpty)
                    }
                    
                    // Live Badge
                    if playerVM.engine.isLiveStream {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 6, height: 6)
                            Text("LIVE")
                                .font(.system(size: 10, weight: .black, design: .rounded))
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.red.opacity(0.15)))
                    }
                    
                    Divider().frame(height: 18)
                    
                    // Volume Booster Slider
                    HStack(spacing: 6) {
                        Button(action: {
                            playerVM.engine.setMuted(playerVM.engine.volume > 0)
                        }) {
                            Image(systemName: playerVM.engine.volume == 0 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .font(.system(size: 13))
                        }
                        .buttonStyle(.plain)
                        
                        Slider(
                            value: Binding(
                                get: { playerVM.engine.volume },
                                set: { playerVM.engine.volume = $0 }
                            ),
                            in: 0...1.0
                        )
                        .frame(width: 70)
                        .tint(.cyan)
                    }
                    
                    Spacer()
                    
                    // Aspect Ratio Picker
                    Menu {
                        ForEach(AspectRatioOption.allCases, id: \.self) { option in
                            Button(option.rawValue) {
                                playerVM.aspectRatio = option
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "aspectratio")
                            Text(playerVM.aspectRatio == .fit ? "Fit" : (playerVM.aspectRatio == .fill ? "Fill" : playerVM.aspectRatio.rawValue))
                                .font(.system(size: 11, weight: .medium))
                        }
                    }
                    .menuStyle(.borderlessButton)
                    .frame(width: 75)
                    
                    // Stream Inspector Toggle (F2)
                    Button(action: onToggleInspector) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    .help("Stream Inspector (⌘I / F2)")
                    
                    // Theater Mode Toggle
                    Button(action: onToggleTheater) {
                        Image(systemName: "rectangle.inset.filled.and.cursorarrow")
                            .font(.system(size: 14))
                    }
                    .buttonStyle(.plain)
                    .help("Toggle Theater Mode")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: 580)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.35), radius: 16, y: 8)
            .padding(.bottom, 20)
        }
        .onHover { _ in
            playerVM.showHUDTemporarily()
        }
    }
    
    private func timeFormatted(_ seconds: TimeInterval) -> String {
        let secs = Int(seconds)
        let m = (secs / 60) % 60
        let s = secs % 60
        let h = secs / 3600
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}

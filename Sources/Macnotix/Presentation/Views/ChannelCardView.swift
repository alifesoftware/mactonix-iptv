import SwiftUI

public struct ChannelCardView: View {
    public let channel: Channel
    public let isPlaying: Bool
    public let isFavorite: Bool
    public let onSelect: () -> Void
    public let onToggleFavorite: () -> Void
    
    @State private var isHovered = false
    @State private var logoImage: NSImage?
    
    public init(
        channel: Channel,
        isPlaying: Bool = false,
        isFavorite: Bool = false,
        onSelect: @escaping () -> Void,
        onToggleFavorite: @escaping () -> Void
    ) {
        self.channel = channel
        self.isPlaying = isPlaying
        self.isFavorite = isFavorite
        self.onSelect = onSelect
        self.onToggleFavorite = onToggleFavorite
    }
    
    public var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                // Top header: flag badge and favorite star
                HStack {
                    if let flag = CountryFlagResolver.shared.resolve(for: channel.groupTitle ?? "")?.flag {
                        Text(flag)
                            .font(.system(size: 16))
                    }
                    Spacer()
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .secondary.opacity(0.6))
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                }
                
                // Optical Logo Box
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.black.opacity(0.2))
                    
                    if let image = logoImage {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(6)
                    } else {
                        Image(systemName: "tv")
                            .font(.system(size: 26))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 52)
                
                // Channel Name & Equalizer
                HStack(spacing: 4) {
                    if isPlaying {
                        Image(systemName: "waveform")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.cyan)
                    }
                    Text(channel.name)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .foregroundColor(isPlaying ? .cyan : .primary)
                }
            }
            .padding(10)
            .frame(width: 154, height: 124)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isPlaying ? AnyShapeStyle(LinearGradient(colors: [.cyan, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)) :
                        (isHovered ? AnyShapeStyle(Color.white.opacity(0.3)) : AnyShapeStyle(Color.white.opacity(0.1))),
                        lineWidth: isPlaying ? 2.0 : 1.0
                    )
            )
            .shadow(color: isPlaying ? Color.cyan.opacity(0.25) : Color.black.opacity(0.15), radius: isPlaying ? 8 : 4, y: 2)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isPlaying)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .task {
            if let logoURL = channel.logoURL {
                logoImage = await ImageCacheActor.shared.image(for: logoURL, targetSize: CGSize(width: 96, height: 64))
            }
        }
    }
}

import SwiftUI

public struct ChannelRowView: View {
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
            HStack(spacing: 12) {
                // Logo or Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.2))
                    if let image = logoImage {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(2)
                    } else {
                        Image(systemName: "tv")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 38, height: 26)
                
                // Channel Details
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        if isPlaying {
                            Image(systemName: "waveform")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.cyan)
                        }
                        Text(channel.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(isPlaying ? .cyan : .primary)
                    }
                    if let group = channel.groupTitle {
                        Text(group)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Favorite Star
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundColor(isFavorite ? .yellow : .secondary.opacity(0.4))
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isPlaying ? Color.cyan.opacity(0.12) : (isHovered ? Color.white.opacity(0.06) : Color.clear))
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .task {
            if let logoURL = channel.logoURL {
                logoImage = await ImageCacheActor.shared.image(for: logoURL, targetSize: CGSize(width: 48, height: 32))
            }
        }
    }
}

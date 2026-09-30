import SwiftUI

public struct MenuBarExtraView: View {
    @ObservedObject public var appVM: AppViewModel
    @ObservedObject public var playerVM: PlayerViewModel
    
    public init(appVM: AppViewModel, playerVM: PlayerViewModel) {
        self.appVM = appVM
        self.playerVM = playerVM
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Now Playing
            HStack(spacing: 8) {
                Image(systemName: "tv.fill")
                    .foregroundColor(.cyan)
                VStack(alignment: .leading, spacing: 1) {
                    Text(playerVM.currentTitle)
                        .font(.system(size: 13, weight: .bold))
                        .lineLimit(1)
                    Text(playerVM.engine.state.rawValue)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: { playerVM.engine.togglePlayPause() }) {
                    Image(systemName: playerVM.engine.state == .playing ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.cyan)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            
            Divider()
            
            // Top Favorites Quick Zapper
            let favoriteChannels = appVM.catalog.channels.filter { appVM.isFavorite(id: $0.streamURL.absoluteString) }
            
            if !favoriteChannels.isEmpty {
                Text("Favorite Channels")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(favoriteChannels.prefix(8)) { channel in
                            Button(action: { playerVM.playChannel(channel) }) {
                                HStack {
                                    Text(channel.name)
                                        .font(.system(size: 12))
                                        .foregroundColor(playerVM.activeChannel?.id == channel.id ? .cyan : .primary)
                                        .lineLimit(1)
                                    Spacer()
                                    if playerVM.activeChannel?.id == channel.id {
                                        Image(systemName: "waveform")
                                            .foregroundColor(.cyan)
                                            .font(.system(size: 10))
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxHeight: 160)
            }
            
            Divider()
            
            // Footer
            HStack {
                Button("Open Macnotix") {
                    NSApp.activate(ignoringOtherApps: true)
                }
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .frame(width: 260)
    }
}

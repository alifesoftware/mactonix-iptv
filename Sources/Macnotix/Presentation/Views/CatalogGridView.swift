import SwiftUI

public struct CatalogGridView: View {
    @ObservedObject public var appVM: AppViewModel
    @ObservedObject public var catalogVM: CatalogViewModel
    @ObservedObject public var playerVM: PlayerViewModel
    public var onlyFavorites: Bool = false
    
    private let gridColumns = [
        GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 12)
    ]
    
    public init(
        appVM: AppViewModel,
        catalogVM: CatalogViewModel,
        playerVM: PlayerViewModel,
        onlyFavorites: Bool = false
    ) {
        self.appVM = appVM
        self.catalogVM = catalogVM
        self.playerVM = playerVM
        self.onlyFavorites = onlyFavorites
    }
    
    public var body: some View {
        let channels = catalogVM.filteredChannels(
            from: appVM.catalog.channels,
            in: appVM.selectedGroup,
            favorites: appVM.favorites,
            onlyFavorites: onlyFavorites
        )
        
        VStack(spacing: 0) {
            // Filter Bar
            HStack(spacing: 12) {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search channels...", text: $catalogVM.searchQuery)
                        .textFieldStyle(.plain)
                    if !catalogVM.searchQuery.isEmpty {
                        Button(action: { catalogVM.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.07)))
                .frame(maxWidth: 240)
                
                Spacer()
                
                // Channel Count
                Text("\(channels.count) channels")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.secondary)
                
                // Grid / List Toggle
                Picker("Layout", selection: $catalogVM.layoutMode) {
                    ForEach(CatalogLayoutMode.allCases, id: \.self) { mode in
                        Image(systemName: mode.iconName).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Channels Container
            if appVM.isLoading {
                VStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                    Text(appVM.statusMessage ?? "Loading...")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else if channels.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: onlyFavorites ? "star.slash" : "tv.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text(onlyFavorites ? "No favorite channels added yet" : "No channels found")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    if catalogVM.layoutMode == .grid {
                        LazyVGrid(columns: gridColumns, spacing: 12) {
                            ForEach(channels) { channel in
                                ChannelCardView(
                                    channel: channel,
                                    isPlaying: playerVM.activeChannel?.id == channel.id,
                                    isFavorite: appVM.isFavorite(id: channel.streamURL.absoluteString),
                                    onSelect: {
                                        playerVM.playChannel(channel, headers: makeHeaders())
                                    },
                                    onToggleFavorite: {
                                        appVM.toggleFavorite(id: channel.streamURL.absoluteString)
                                    }
                                )
                            }
                        }
                        .padding(14)
                    } else {
                        LazyVStack(spacing: 4) {
                            ForEach(channels) { channel in
                                ChannelRowView(
                                    channel: channel,
                                    isPlaying: playerVM.activeChannel?.id == channel.id,
                                    isFavorite: appVM.isFavorite(id: channel.streamURL.absoluteString),
                                    onSelect: {
                                        playerVM.playChannel(channel, headers: makeHeaders())
                                    },
                                    onToggleFavorite: {
                                        appVM.toggleFavorite(id: channel.streamURL.absoluteString)
                                    }
                                )
                            }
                        }
                        .padding(10)
                    }
                }
            }
        }
    }
    
    private func makeHeaders() -> [String: String]? {
        guard let p = appVM.activeProvider else { return nil }
        var h: [String: String] = [:]
        if let ua = p.userAgent { h["User-Agent"] = ua }
        if let ref = p.httpReferer { h["Referer"] = ref }
        return h.isEmpty ? nil : h
    }
}

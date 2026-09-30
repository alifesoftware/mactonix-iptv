import SwiftUI

public struct SeriesCatalogView: View {
    @ObservedObject public var appVM: AppViewModel
    @ObservedObject public var catalogVM: CatalogViewModel
    @ObservedObject public var playerVM: PlayerViewModel
    
    @State private var selectedSerie: Serie?
    @State private var seasons: [Season] = []
    @State private var isLoadingEpisodes: Bool = false
    
    private let seriesColumns = [
        GridItem(.adaptive(minimum: 140, maximum: 170), spacing: 14)
    ]
    
    public init(
        appVM: AppViewModel,
        catalogVM: CatalogViewModel,
        playerVM: PlayerViewModel
    ) {
        self.appVM = appVM
        self.catalogVM = catalogVM
        self.playerVM = playerVM
    }
    
    public var body: some View {
        let series = catalogVM.filteredSeries(from: appVM.catalog.series, in: appVM.selectedGroup)
        
        VStack(spacing: 0) {
            // Search Header
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                    TextField("Search TV series...", text: $catalogVM.searchQuery)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.07)))
                .frame(maxWidth: 240)
                
                Spacer()
                Text("\(series.count) series").font(.system(size: 11, design: .rounded)).foregroundColor(.secondary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            
            Divider()
            
            if series.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "play.rectangle.on.rectangle")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No TV series found").font(.system(size: 14, weight: .medium)).foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: seriesColumns, spacing: 16) {
                        ForEach(series) { serie in
                            SeriesPosterCard(serie: serie) {
                                openSeriesDetail(serie)
                            }
                        }
                    }
                    .padding(14)
                }
            }
        }
        .sheet(item: $selectedSerie) { serie in
            SeriesDetailSheet(
                serie: serie,
                seasons: seasons,
                isLoading: isLoadingEpisodes,
                onPlayEpisode: { ep in
                    playerVM.playEpisode(ep, seriesName: serie.name)
                    selectedSerie = nil
                },
                onClose: { selectedSerie = nil }
            )
        }
    }
    
    private func openSeriesDetail(_ serie: Serie) {
        self.selectedSerie = serie
        if !serie.seasons.isEmpty {
            self.seasons = serie.seasons
        } else if let p = appVM.activeProvider {
            self.isLoadingEpisodes = true
            let adapter = ProviderAdapterFactory.makeAdapter(for: p)
            Task {
                let fetched = (try? await adapter.fetchSeriesDetails(seriesId: serie.seriesId)) ?? []
                await MainActor.run {
                    self.seasons = fetched
                    self.isLoadingEpisodes = false
                }
            }
        }
    }
}

private struct SeriesPosterCard: View {
    let serie: Serie
    let onSelect: () -> Void
    @State private var isHovered = false
    @State private var posterImage: NSImage?
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.3))
                    if let img = posterImage {
                        Image(nsImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                            .cornerRadius(10)
                    } else {
                        Image(systemName: "play.rectangle.on.rectangle")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 200)
                
                Text(serie.name)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
            }
            .frame(width: 140)
            .scaleEffect(isHovered ? 1.03 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .task {
            if let url = serie.posterURL {
                posterImage = await ImageCacheActor.shared.image(for: url, targetSize: CGSize(width: 140, height: 200))
            }
        }
    }
}

private struct SeriesDetailSheet: View {
    let serie: Serie
    let seasons: [Season]
    let isLoading: Bool
    let onPlayEpisode: (Episode) -> Void
    let onClose: () -> Void
    
    @State private var selectedSeasonIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Sheet Header
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(serie.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    if let plot = serie.plot {
                        Text(plot)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .background(.ultraThinMaterial)
            
            Divider()
            
            if isLoading {
                VStack(spacing: 12) {
                    Spacer()
                    ProgressView()
                    Text("Loading episodes...").foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if seasons.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Text("No episodes available").foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    // Season Picker Tab Bar
                    if seasons.count > 1 {
                        Picker("Season", selection: $selectedSeasonIndex) {
                            ForEach(0..<seasons.count, id: \.self) { idx in
                                Text(seasons[idx].name).tag(idx)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        .padding(12)
                    }
                    
                    // Episodes List
                    let currentSeason = seasons[min(selectedSeasonIndex, seasons.count - 1)]
                    List(currentSeason.episodes) { ep in
                        HStack(spacing: 12) {
                            Text("Ep \(ep.episodeNumber)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.cyan)
                                .frame(width: 48, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ep.title)
                                    .font(.system(size: 13, weight: .medium))
                                if let plot = ep.plot {
                                    Text(plot)
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { onPlayEpisode(ep) }) {
                                Label("Play", systemImage: "play.fill")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.cyan)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .resizableSheet(minWidth: 520, idealWidth: 640, minHeight: 380, idealHeight: 480)
    }
}

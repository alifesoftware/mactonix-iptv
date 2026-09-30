import Foundation

public struct XtreamCodesAdapter: ProviderSource {
    public let provider: Provider
    private let client = XtreamClientActor.shared
    
    public init(provider: Provider) {
        self.provider = provider
    }
    
    public func testConnection() async throws -> Bool {
        let auth = try await client.authenticate(provider: provider)
        return auth.userInfo?.status?.lowercased() == "active" || auth.userInfo?.username != nil
    }
    
    public func loadCatalog() async throws -> ProviderCatalog {
        // Authenticate first
        _ = try await client.authenticate(provider: provider)
        
        // Fetch categories and streams concurrently
        async let liveCatsTask = client.fetchLiveCategories(provider: provider)
        async let vodCatsTask = client.fetchVODCategories(provider: provider)
        async let seriesCatsTask = client.fetchSeriesCategories(provider: provider)
        async let liveStreamsTask = client.fetchLiveStreams(provider: provider)
        async let vodStreamsTask = client.fetchVODStreams(provider: provider)
        async let seriesTask = client.fetchSeries(provider: provider)
        
        let (liveCats, vodCats, seriesCats, channels, movies, series) = try await (
            liveCatsTask, vodCatsTask, seriesCatsTask, liveStreamsTask, vodStreamsTask, seriesTask
        )
        
        let liveGroups = liveCats.map { cat in
            let count = channels.filter { $0.groupTitle == cat.categoryName || $0.groupTitle == cat.categoryId }.count
            let flagInfo = CountryFlagResolver.shared.resolve(for: cat.categoryName)
            return Group(
                name: cat.categoryName,
                groupType: .live,
                countryCode: flagInfo?.code,
                flagEmoji: flagInfo?.flag,
                channelCount: count
            )
        }.sorted(by: { $0.name < $1.name })
        
        let movieGroups = vodCats.map { cat in
            let count = movies.filter { $0.groupTitle == cat.categoryName }.count
            return Group(
                name: cat.categoryName,
                groupType: .movie,
                channelCount: count
            )
        }.sorted(by: { $0.name < $1.name })
        
        let seriesGroups = seriesCats.map { cat in
            let count = series.filter { $0.groupTitle == cat.categoryName }.count
            return Group(
                name: cat.categoryName,
                groupType: .series,
                channelCount: count
            )
        }.sorted(by: { $0.name < $1.name })
        
        return ProviderCatalog(
            liveGroups: liveGroups,
            movieGroups: movieGroups,
            seriesGroups: seriesGroups,
            channels: channels,
            movies: movies,
            series: series
        )
    }
    
    public func fetchSeriesDetails(seriesId: String) async throws -> [Season] {
        return try await client.fetchSeriesInfo(provider: provider, seriesId: seriesId)
    }
    
    public func fetchEPG(for channelId: String) async throws -> [EPGProgram] {
        return []
    }
}

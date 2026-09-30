import Foundation

public struct ProviderCatalog: Sendable {
    public let liveGroups: [Group]
    public let movieGroups: [Group]
    public let seriesGroups: [Group]
    public let channels: [Channel]
    public let movies: [Movie]
    public let series: [Serie]
    
    public init(
        liveGroups: [Group] = [],
        movieGroups: [Group] = [],
        seriesGroups: [Group] = [],
        channels: [Channel] = [],
        movies: [Movie] = [],
        series: [Serie] = []
    ) {
        self.liveGroups = liveGroups
        self.movieGroups = movieGroups
        self.seriesGroups = seriesGroups
        self.channels = channels
        self.movies = movies
        self.series = series
    }
}

public protocol ProviderSource: Sendable {
    var provider: Provider { get }
    func testConnection() async throws -> Bool
    func loadCatalog() async throws -> ProviderCatalog
    func fetchSeriesDetails(seriesId: String) async throws -> [Season]
    func fetchEPG(for channelId: String) async throws -> [EPGProgram]
}

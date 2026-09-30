import Foundation

public struct DirectStreamAdapter: ProviderSource {
    public let provider: Provider
    
    public init(provider: Provider) {
        self.provider = provider
    }
    
    public func testConnection() async throws -> Bool {
        guard let url = URL(string: provider.url) else { return false }
        var request = URLRequest(url: url)
        request.timeoutInterval = 4.0
        let (_, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse {
            return (200...399).contains(http.statusCode)
        }
        return false
    }
    
    public func loadCatalog() async throws -> ProviderCatalog {
        guard let url = URL(string: provider.url) else {
            throw URLError(.badURL)
        }
        
        let channel = Channel(
            providerId: provider.id,
            name: provider.name.isEmpty ? "Direct Stream" : provider.name,
            streamURL: url,
            groupTitle: "Direct"
        )
        
        let group = Group(
            name: "Direct",
            groupType: .live,
            flagEmoji: "▶️",
            channelCount: 1
        )
        
        return ProviderCatalog(
            liveGroups: [group],
            channels: [channel]
        )
    }
    
    public func fetchSeriesDetails(seriesId: String) async throws -> [Season] {
        return []
    }
    
    public func fetchEPG(for channelId: String) async throws -> [EPGProgram] {
        return []
    }
}

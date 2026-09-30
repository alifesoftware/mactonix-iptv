import Foundation

public struct StalkerhekAdapter: ProviderSource {
    public let provider: Provider
    private let parser = M3UParserActor.shared
    
    public init(provider: Provider) {
        self.provider = provider
    }
    
    public func testConnection() async throws -> Bool {
        guard let url = URL(string: cleanURL(provider.url)) else {
            return false
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 4.0
        if let ua = provider.userAgent {
            request.setValue(ua, forHTTPHeaderField: "User-Agent")
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            return (200...399).contains(httpResponse.statusCode)
        }
        return false
    }
    
    public func loadCatalog() async throws -> ProviderCatalog {
        guard let url = URL(string: cleanURL(provider.url)) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        if let ua = provider.userAgent {
            request.setValue(ua, forHTTPHeaderField: "User-Agent")
        }
        if let referer = provider.httpReferer {
            request.setValue(referer, forHTTPHeaderField: "Referer")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        guard let bodyString = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        // If response is an M3U playlist with #EXTINF
        if bodyString.contains("#EXTINF:") {
            let parsed = await parser.parse(content: bodyString, provider: provider)
            return ProviderCatalog(
                liveGroups: parsed.groups.filter { $0.groupType == .live },
                movieGroups: parsed.groups.filter { $0.groupType == .movie },
                seriesGroups: parsed.groups.filter { $0.groupType == .series },
                channels: parsed.channels,
                movies: parsed.movies,
                series: parsed.series
            )
        } else {
            // Direct HLS stream or single channel on localhost
            let channel = Channel(
                providerId: provider.id,
                name: provider.name.isEmpty ? "Stalkerhek Live" : provider.name,
                streamURL: url,
                groupTitle: "Local Proxy"
            )
            let group = Group(
                name: "Local Proxy",
                groupType: .live,
                flagEmoji: "📡",
                channelCount: 1
            )
            return ProviderCatalog(
                liveGroups: [group],
                channels: [channel]
            )
        }
    }
    
    public func fetchSeriesDetails(seriesId: String) async throws -> [Season] {
        return []
    }
    
    public func fetchEPG(for channelId: String) async throws -> [EPGProgram] {
        return []
    }
    
    private func cleanURL(_ urlString: String) -> String {
        var s = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.hasPrefix("http://") && !s.hasPrefix("https://") {
            s = "http://" + s
        }
        return s
    }
}

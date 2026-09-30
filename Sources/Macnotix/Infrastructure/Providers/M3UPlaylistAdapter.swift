import Foundation

public struct M3UPlaylistAdapter: ProviderSource {
    public let provider: Provider
    private let parser = M3UParserActor.shared
    
    public init(provider: Provider) {
        self.provider = provider
    }
    
    public func testConnection() async throws -> Bool {
        if provider.type == .m3uLocal {
            let path = provider.url.replacingOccurrences(of: "file://", with: "")
            return FileManager.default.fileExists(atPath: path)
        }
        
        guard let url = URL(string: provider.url) else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 5.0
        if let ua = provider.userAgent { request.setValue(ua, forHTTPHeaderField: "User-Agent") }
        let (_, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse {
            return (200...399).contains(http.statusCode)
        }
        return false
    }
    
    public func loadCatalog() async throws -> ProviderCatalog {
        let content: String
        
        if provider.type == .m3uLocal {
            let path = provider.url.replacingOccurrences(of: "file://", with: "")
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            guard let str = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
                throw URLError(.cannotDecodeContentData)
            }
            content = str
        } else {
            guard let url = URL(string: provider.url) else {
                throw URLError(.badURL)
            }
            var request = URLRequest(url: url)
            request.timeoutInterval = 30.0
            if let ua = provider.userAgent { request.setValue(ua, forHTTPHeaderField: "User-Agent") }
            if let referer = provider.httpReferer { request.setValue(referer, forHTTPHeaderField: "Referer") }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
                throw URLError(.badServerResponse)
            }
            guard let str = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
                throw URLError(.cannotDecodeContentData)
            }
            content = str
        }
        
        let parsed = await parser.parse(content: content, provider: provider)
        return ProviderCatalog(
            liveGroups: parsed.groups.filter { $0.groupType == .live },
            movieGroups: parsed.groups.filter { $0.groupType == .movie },
            seriesGroups: parsed.groups.filter { $0.groupType == .series },
            channels: parsed.channels,
            movies: parsed.movies,
            series: parsed.series
        )
    }
    
    public func fetchSeriesDetails(seriesId: String) async throws -> [Season] {
        return []
    }
    
    public func fetchEPG(for channelId: String) async throws -> [EPGProgram] {
        return []
    }
}

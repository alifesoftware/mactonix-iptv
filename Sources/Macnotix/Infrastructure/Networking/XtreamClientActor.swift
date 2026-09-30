import Foundation

public struct XtreamAuthResponse: Codable, Sendable {
    public let userInfo: XtreamUserInfo?
    public let serverInfo: XtreamServerInfo?
    
    enum CodingKeys: String, CodingKey {
        case userInfo = "user_info"
        case serverInfo = "server_info"
    }
}

public struct XtreamUserInfo: Codable, Sendable {
    public let username: String?
    public let status: String?
    public let expDate: String?
    public let isTrial: String?
    public let activeCons: String?
    public let maxCons: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case status
        case expDate = "exp_date"
        case isTrial = "is_trial"
        case activeCons = "active_cons"
        case maxCons = "max_connections"
    }
}

public struct XtreamServerInfo: Codable, Sendable {
    public let url: String?
    public let port: String?
    public let serverProtocol: String?
    public let timezone: String?
    
    enum CodingKeys: String, CodingKey {
        case url
        case port
        case serverProtocol = "server_protocol"
        case timezone
    }
}

public struct XtreamCategory: Codable, Sendable {
    public let categoryId: String
    public let categoryName: String
    
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id"
        case categoryName = "category_name"
    }
}

public actor XtreamClientActor {
    public static let shared = XtreamClientActor()
    private let session: URLSession
    
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 60.0
        self.session = URLSession(configuration: config)
    }
    
    public func authenticate(provider: Provider) async throws -> XtreamAuthResponse {
        let url = makeURL(provider: provider)
        let data = try await fetchData(from: url, userAgent: provider.userAgent)
        let response = try JSONDecoder().decode(XtreamAuthResponse.self, from: data)
        return response
    }
    
    public func fetchLiveCategories(provider: Provider) async throws -> [XtreamCategory] {
        let url = makeURL(provider: provider, queryItems: [URLQueryItem(name: "action", value: "get_live_categories")])
        let data = try await fetchData(from: url, userAgent: provider.userAgent)
        return (try? JSONDecoder().decode([XtreamCategory].self, from: data)) ?? []
    }
    
    public func fetchVODCategories(provider: Provider) async throws -> [XtreamCategory] {
        let url = makeURL(provider: provider, queryItems: [URLQueryItem(name: "action", value: "get_vod_categories")])
        let data = try await fetchData(from: url, userAgent: provider.userAgent)
        return (try? JSONDecoder().decode([XtreamCategory].self, from: data)) ?? []
    }
    
    public func fetchSeriesCategories(provider: Provider) async throws -> [XtreamCategory] {
        let url = makeURL(provider: provider, queryItems: [URLQueryItem(name: "action", value: "get_series_categories")])
        let data = try await fetchData(from: url, userAgent: provider.userAgent)
        return (try? JSONDecoder().decode([XtreamCategory].self, from: data)) ?? []
    }
    
    public func fetchLiveStreams(provider: Provider) async throws -> [Channel] {
        let url = makeURL(provider: provider, queryItems: [URLQueryItem(name: "action", value: "get_live_streams")])
        let data = try await fetchData(from: url, userAgent: provider.userAgent)
        
        guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        let server = cleanServerURL(provider.url)
        let user = provider.username ?? ""
        let pass = provider.password ?? ""
        
        return jsonArray.compactMap { dict in
            guard let name = dict["name"] as? String,
                  let streamId = dict["stream_id"] as? Int else {
                return nil
            }
            let logoStr = dict["stream_icon"] as? String
            let logoURL = logoStr.flatMap { URL(string: $0) }
            let groupTitle = dict["category_name"] as? String ?? dict["category_id"] as? String
            let streamURLString = "\(server)/live/\(user)/\(pass)/\(streamId).ts"
            guard let streamURL = URL(string: streamURLString) else { return nil }
            
            return Channel(
                providerId: provider.id,
                name: name,
                streamURL: streamURL,
                logoURL: logoURL,
                groupTitle: groupTitle,
                tvgId: dict["epg_channel_id"] as? String,
                isAdult: (dict["is_adult"] as? String == "1" || dict["is_adult"] as? Int == 1),
                streamId: streamId
            )
        }
    }
    
    public func fetchVODStreams(provider: Provider) async throws -> [Movie] {
        let url = makeURL(provider: provider, queryItems: [URLQueryItem(name: "action", value: "get_vod_streams")])
        let data = try await fetchData(from: url, userAgent: provider.userAgent)
        
        guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        let server = cleanServerURL(provider.url)
        let user = provider.username ?? ""
        let pass = provider.password ?? ""
        
        return jsonArray.compactMap { dict in
            guard let name = dict["name"] as? String,
                  let streamId = dict["stream_id"] as? Int else {
                return nil
            }
            let ext = (dict["container_extension"] as? String) ?? "mp4"
            let logoStr = dict["stream_icon"] as? String
            let posterURL = logoStr.flatMap { URL(string: $0) }
            let groupTitle = dict["category_name"] as? String
            let streamURLString = "\(server)/movie/\(user)/\(pass)/\(streamId).\(ext)"
            guard let streamURL = URL(string: streamURLString) else { return nil }
            
            let rating = (dict["rating"] as? Double) ?? (dict["rating_5based"] as? Double)
            
            return Movie(
                providerId: provider.id,
                name: name,
                streamURL: streamURL,
                posterURL: posterURL,
                groupTitle: groupTitle,
                rating: rating,
                containerExtension: ext,
                streamId: streamId
            )
        }
    }
    
    public func fetchSeries(provider: Provider) async throws -> [Serie] {
        let url = makeURL(provider: provider, queryItems: [URLQueryItem(name: "action", value: "get_series")])
        let data = try await fetchData(from: url, userAgent: provider.userAgent)
        
        guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        return jsonArray.compactMap { dict in
            guard let name = dict["name"] as? String,
                  let seriesIdNum = dict["series_id"] as? Int else {
                return nil
            }
            let seriesId = String(seriesIdNum)
            let coverStr = dict["cover"] as? String
            let posterURL = coverStr.flatMap { URL(string: $0) }
            let groupTitle = dict["category_name"] as? String
            let plot = dict["plot"] as? String
            let cast = dict["cast"] as? String
            let genre = dict["genre"] as? String
            let releaseDate = dict["releaseDate"] as? String
            let rating = (dict["rating"] as? Double) ?? (dict["rating_5based"] as? Double)
            let trailer = dict["youtube_trailer"] as? String
            
            return Serie(
                providerId: provider.id,
                seriesId: seriesId,
                name: name,
                posterURL: posterURL,
                groupTitle: groupTitle,
                plot: plot,
                cast: cast,
                genre: genre,
                releaseDate: releaseDate,
                rating: rating,
                youtubeTrailer: trailer
            )
        }
    }
    
    public func fetchSeriesInfo(provider: Provider, seriesId: String) async throws -> [Season] {
        let url = makeURL(provider: provider, queryItems: [
            URLQueryItem(name: "action", value: "get_series_info"),
            URLQueryItem(name: "series_id", value: seriesId)
        ])
        let data = try await fetchData(from: url, userAgent: provider.userAgent)
        guard let jsonDict = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let episodesDict = jsonDict["episodes"] as? [String: [[String: Any]]] else {
            return []
        }
        
        let server = cleanServerURL(provider.url)
        let user = provider.username ?? ""
        let pass = provider.password ?? ""
        
        var seasons: [Season] = []
        for (seasonNumStr, epList) in episodesDict {
            let seasonNum = Int(seasonNumStr) ?? 1
            var episodes: [Episode] = []
            
            for epDict in epList {
                guard let epId = epDict["id"] as? String ?? (epDict["id"] as? Int).map(String.init),
                      let epTitle = epDict["title"] as? String else {
                    continue
                }
                let ext = (epDict["container_extension"] as? String) ?? "mp4"
                let epNum = (epDict["episode_num"] as? Int) ?? 1
                let streamURLString = "\(server)/series/\(user)/\(pass)/\(epId).\(ext)"
                guard let streamURL = URL(string: streamURLString) else { continue }
                
                let epInfo = epDict["info"] as? [String: Any]
                let plot = epInfo?["plot"] as? String
                let durationSecs = epInfo?["duration_secs"] as? Int
                
                let episode = Episode(
                    episodeId: epId,
                    title: epTitle,
                    episodeNumber: epNum,
                    seasonNumber: seasonNum,
                    streamURL: streamURL,
                    plot: plot,
                    durationSecs: durationSecs,
                    containerExtension: ext
                )
                episodes.append(episode)
            }
            
            seasons.append(Season(
                seasonNumber: seasonNum,
                name: "Season \(seasonNum)",
                episodes: episodes.sorted(by: { $0.episodeNumber < $1.episodeNumber })
            ))
        }
        
        return seasons.sorted(by: { $0.seasonNumber < $1.seasonNumber })
    }
    
    private func cleanServerURL(_ urlStr: String) -> String {
        var s = urlStr.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasSuffix("/") { s.removeLast() }
        if !s.hasPrefix("http://") && !s.hasPrefix("https://") {
            s = "http://" + s
        }
        return s
    }
    
    private func makeURL(provider: Provider, queryItems: [URLQueryItem] = []) -> URL {
        let server = cleanServerURL(provider.url)
        var components = URLComponents(string: "\(server)/player_api.php")!
        var items = [
            URLQueryItem(name: "username", value: provider.username ?? ""),
            URLQueryItem(name: "password", value: provider.password ?? "")
        ]
        items.append(contentsOf: queryItems)
        components.queryItems = items
        return components.url!
    }
    
    private func fetchData(from url: URL, userAgent: String?) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue(userAgent ?? "Macnotix/1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
}

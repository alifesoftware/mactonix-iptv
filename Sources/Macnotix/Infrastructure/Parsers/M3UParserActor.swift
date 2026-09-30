import Foundation

public actor M3UParserActor {
    public static let shared = M3UParserActor()
    
    private let seriesRegex = try? NSRegularExpression(
        pattern: #"^(.*?)\s+S(\d{1,2})\s*E(\d{1,2})(.*)$"#,
        options: .caseInsensitive
    )
    
    public init() {}
    
    public struct ParsedM3UResult: Sendable {
        public let channels: [Channel]
        public let movies: [Movie]
        public let series: [Serie]
        public let groups: [Group]
    }
    
    public func parse(content: String, provider: Provider) -> ParsedM3UResult {
        var channels: [Channel] = []
        var movies: [Movie] = []
        var seriesMap: [String: Serie] = [:]
        var groupsMap: [String: Group] = [:]
        
        var currentTvgName: String?
        var currentTvgLogo: String?
        var currentTvgId: String?
        var currentGroupTitle: String?
        var currentTitle: String?
        
        let lines = content.components(separatedBy: .newlines)
        
        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if line.isEmpty || line.hasPrefix("#EXTM3U") {
                continue
            }
            
            if line.hasPrefix("#EXTINF:") {
                // Parse #EXTINF:-1 tvg-id="..." tvg-name="..." tvg-logo="..." group-title="...", Channel Name
                currentTvgName = nil
                currentTvgLogo = nil
                currentTvgId = nil
                currentGroupTitle = nil
                currentTitle = nil
                
                let infoPart = String(line.dropFirst(8))
                
                // Extract parameters
                if let commaIndex = infoPart.firstIndex(of: ",") {
                    let paramsString = String(infoPart[..<commaIndex])
                    let titleString = String(infoPart[infoPart.index(after: commaIndex)...]).trimmingCharacters(in: .whitespaces)
                    currentTitle = titleString
                    
                    currentTvgName = extractAttribute(named: "tvg-name", from: paramsString)
                    currentTvgLogo = extractAttribute(named: "tvg-logo", from: paramsString)
                    currentTvgId = extractAttribute(named: "tvg-id", from: paramsString)
                    currentGroupTitle = extractAttribute(named: "group-title", from: paramsString)
                } else {
                    currentTitle = infoPart
                }
                continue
            }
            
            // If it's a URL line (http, https, file, or anything not starting with #)
            if !line.hasPrefix("#"), let streamURL = URL(string: line) {
                let channelName = currentTitle ?? currentTvgName ?? "Channel \(channels.count + 1)"
                let logoURL = currentTvgLogo.flatMap { URL(string: $0) }
                let groupName = currentGroupTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "General"
                
                // Determine group type: Movies, Series, or Live
                let upperGroup = groupName.uppercased()
                let isMovie = upperGroup.contains("VOD") || upperGroup.contains("MOVIE")
                let isSeries = upperGroup.contains("SERIES") || upperGroup.contains("SEASON")
                
                // Check if title matches series pattern "Show Name S01E02"
                if let seriesMatch = matchSeries(title: channelName) {
                    let seriesTitle = seriesMatch.seriesTitle
                    let seasonNum = seriesMatch.seasonNumber
                    let episodeNum = seriesMatch.episodeNumber
                    
                    var serie = seriesMap[seriesTitle] ?? Serie(
                        providerId: provider.id,
                        seriesId: seriesTitle,
                        name: seriesTitle,
                        posterURL: logoURL,
                        groupTitle: groupName
                    )
                    
                    let episode = Episode(
                        episodeId: "\(seriesTitle)_S\(seasonNum)E\(episodeNum)",
                        title: channelName,
                        episodeNumber: episodeNum,
                        seasonNumber: seasonNum,
                        streamURL: streamURL,
                        thumbnailURL: logoURL
                    )
                    
                    if let sIndex = serie.seasons.firstIndex(where: { $0.seasonNumber == seasonNum }) {
                        serie.seasons[sIndex].episodes.append(episode)
                    } else {
                        let newSeason = Season(seasonNumber: seasonNum, name: "Season \(seasonNum)", episodes: [episode])
                        serie.seasons.append(newSeason)
                    }
                    
                    seriesMap[seriesTitle] = serie
                } else if isMovie {
                    let movie = Movie(
                        providerId: provider.id,
                        name: channelName,
                        streamURL: streamURL,
                        posterURL: logoURL,
                        groupTitle: groupName
                    )
                    movies.append(movie)
                } else {
                    let channel = Channel(
                        providerId: provider.id,
                        name: channelName,
                        title: currentTitle,
                        streamURL: streamURL,
                        logoURL: logoURL,
                        groupTitle: groupName,
                        tvgId: currentTvgId,
                        tvgName: currentTvgName
                    )
                    channels.append(channel)
                }
                
                // Update group
                if var existing = groupsMap[groupName] {
                    existing.channelCount += 1
                    groupsMap[groupName] = existing
                } else {
                    let groupType: ContentGroupType = isSeries ? .series : (isMovie ? .movie : .live)
                    let flagInfo = CountryFlagResolver.shared.resolve(for: groupName)
                    let newGroup = Group(
                        name: groupName,
                        groupType: groupType,
                        countryCode: flagInfo?.code,
                        flagEmoji: flagInfo?.flag,
                        channelCount: 1
                    )
                    groupsMap[groupName] = newGroup
                }
                
                // Reset per-channel temp variables
                currentTvgName = nil
                currentTvgLogo = nil
                currentTvgId = nil
                currentGroupTitle = nil
                currentTitle = nil
            }
        }
        
        return ParsedM3UResult(
            channels: channels,
            movies: movies,
            series: Array(seriesMap.values),
            groups: Array(groupsMap.values).sorted(by: { $0.name < $1.name })
        )
    }
    
    private func extractAttribute(named name: String, from text: String) -> String? {
        // e.g. tvg-logo="http://..." or group-title="UK"
        let pattern = "\(name)=\"([^\"]*)\""
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
              let match = regex.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)),
              let range = Range(match.range(at: 1), in: text) else {
            return nil
        }
        let val = String(text[range]).trimmingCharacters(in: .whitespaces)
        return val.isEmpty ? nil : val
    }
    
    private func matchSeries(title: String) -> (seriesTitle: String, seasonNumber: Int, episodeNumber: Int)? {
        guard let regex = seriesRegex else { return nil }
        let nsTitle = title as NSString
        let matches = regex.matches(in: title, options: [], range: NSRange(location: 0, length: nsTitle.length))
        guard let match = matches.first, match.numberOfRanges >= 4 else { return nil }
        
        let seriesTitle = nsTitle.substring(with: match.range(at: 1)).trimmingCharacters(in: .whitespaces)
        let seasonNum = Int(nsTitle.substring(with: match.range(at: 2))) ?? 1
        let episodeNum = Int(nsTitle.substring(with: match.range(at: 3))) ?? 1
        return (seriesTitle, seasonNum, episodeNum)
    }
}

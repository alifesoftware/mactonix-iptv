import Foundation

public struct Episode: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let episodeId: String
    public var title: String
    public var episodeNumber: Int
    public var seasonNumber: Int
    public var streamURL: URL
    public var thumbnailURL: URL?
    public var plot: String?
    public var durationSecs: Int?
    public var containerExtension: String?
    
    public init(
        id: UUID = UUID(),
        episodeId: String,
        title: String,
        episodeNumber: Int,
        seasonNumber: Int,
        streamURL: URL,
        thumbnailURL: URL? = nil,
        plot: String? = nil,
        durationSecs: Int? = nil,
        containerExtension: String? = "mp4"
    ) {
        self.id = id
        self.episodeId = episodeId
        self.title = title
        self.episodeNumber = episodeNumber
        self.seasonNumber = seasonNumber
        self.streamURL = streamURL
        self.thumbnailURL = thumbnailURL
        self.plot = plot
        self.durationSecs = durationSecs
        self.containerExtension = containerExtension
    }
}

public struct Season: Identifiable, Codable, Hashable, Sendable {
    public var id: Int { seasonNumber }
    public let seasonNumber: Int
    public var name: String
    public var episodes: [Episode]
    
    public init(seasonNumber: Int, name: String, episodes: [Episode] = []) {
        self.seasonNumber = seasonNumber
        self.name = name
        self.episodes = episodes
    }
}

public struct Serie: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let providerId: UUID
    public var seriesId: String
    public var name: String
    public var posterURL: URL?
    public var groupTitle: String?
    public var plot: String?
    public var cast: String?
    public var genre: String?
    public var releaseDate: String?
    public var rating: Double?
    public var youtubeTrailer: String?
    public var seasons: [Season]
    public var isFavorite: Bool
    
    public init(
        id: UUID = UUID(),
        providerId: UUID,
        seriesId: String,
        name: String,
        posterURL: URL? = nil,
        groupTitle: String? = nil,
        plot: String? = nil,
        cast: String? = nil,
        genre: String? = nil,
        releaseDate: String? = nil,
        rating: Double? = nil,
        youtubeTrailer: String? = nil,
        seasons: [Season] = [],
        isFavorite: Bool = false
    ) {
        self.id = id
        self.providerId = providerId
        self.seriesId = seriesId
        self.name = name
        self.posterURL = posterURL
        self.groupTitle = groupTitle
        self.plot = plot
        self.cast = cast
        self.genre = genre
        self.releaseDate = releaseDate
        self.rating = rating
        self.youtubeTrailer = youtubeTrailer
        self.seasons = seasons
        self.isFavorite = isFavorite
    }
}

import Foundation

public struct Movie: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let providerId: UUID
    public var name: String
    public var streamURL: URL
    public var posterURL: URL?
    public var groupTitle: String?
    public var plot: String?
    public var cast: String?
    public var director: String?
    public var genre: String?
    public var releaseDate: String?
    public var durationSecs: Int?
    public var rating: Double?
    public var containerExtension: String?
    public var streamId: Int?
    public var isFavorite: Bool
    
    public init(
        id: UUID = UUID(),
        providerId: UUID,
        name: String,
        streamURL: URL,
        posterURL: URL? = nil,
        groupTitle: String? = nil,
        plot: String? = nil,
        cast: String? = nil,
        director: String? = nil,
        genre: String? = nil,
        releaseDate: String? = nil,
        durationSecs: Int? = nil,
        rating: Double? = nil,
        containerExtension: String? = "mp4",
        streamId: Int? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.providerId = providerId
        self.name = name
        self.streamURL = streamURL
        self.posterURL = posterURL
        self.groupTitle = groupTitle
        self.plot = plot
        self.cast = cast
        self.director = director
        self.genre = genre
        self.releaseDate = releaseDate
        self.durationSecs = durationSecs
        self.rating = rating
        self.containerExtension = containerExtension
        self.streamId = streamId
        self.isFavorite = isFavorite
    }
}

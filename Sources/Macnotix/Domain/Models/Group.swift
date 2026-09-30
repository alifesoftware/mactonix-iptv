import Foundation

public enum ContentGroupType: String, Codable, CaseIterable, Sendable {
    case live = "live"
    case movie = "movie"
    case series = "series"
    
    public var title: String {
        switch self {
        case .live: return "Live TV"
        case .movie: return "Movies"
        case .series: return "Series"
        }
    }
    
    public var iconName: String {
        switch self {
        case .live: return "tv"
        case .movie: return "film"
        case .series: return "play.rectangle.on.rectangle"
        }
    }
}

public struct Group: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let name: String
    public let groupType: ContentGroupType
    public var countryCode: String?
    public var flagEmoji: String?
    public var channelCount: Int
    
    public init(
        id: UUID = UUID(),
        name: String,
        groupType: ContentGroupType = .live,
        countryCode: String? = nil,
        flagEmoji: String? = nil,
        channelCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.groupType = groupType
        self.countryCode = countryCode
        self.flagEmoji = flagEmoji
        self.channelCount = channelCount
    }
}

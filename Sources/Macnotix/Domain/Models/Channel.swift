import Foundation

public struct Channel: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let providerId: UUID
    public var name: String
    public var title: String?
    public var streamURL: URL
    public var logoURL: URL?
    public var groupTitle: String?
    public var tvgId: String?
    public var tvgName: String?
    public var epgChannelId: String?
    public var isFavorite: Bool
    public var isAdult: Bool
    public var streamId: Int?
    
    public init(
        id: UUID = UUID(),
        providerId: UUID,
        name: String,
        title: String? = nil,
        streamURL: URL,
        logoURL: URL? = nil,
        groupTitle: String? = nil,
        tvgId: String? = nil,
        tvgName: String? = nil,
        epgChannelId: String? = nil,
        isFavorite: Bool = false,
        isAdult: Bool = false,
        streamId: Int? = nil
    ) {
        self.id = id
        self.providerId = providerId
        self.name = name
        self.title = title
        self.streamURL = streamURL
        self.logoURL = logoURL
        self.groupTitle = groupTitle
        self.tvgId = tvgId
        self.tvgName = tvgName
        self.epgChannelId = epgChannelId
        self.isFavorite = isFavorite
        self.isAdult = isAdult
        self.streamId = streamId
    }
}

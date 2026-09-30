import Foundation

public enum ProviderType: String, Codable, CaseIterable, Sendable {
    case stalkerhek = "stalkerhek"
    case xtream = "xtream"
    case m3uURL = "m3uURL"
    case m3uLocal = "m3uLocal"
    case directStream = "directStream"
    
    public var displayName: String {
        switch self {
        case .stalkerhek: return "Stalker / Local Proxy"
        case .xtream: return "Xtream Codes"
        case .m3uURL: return "M3U Playlist URL"
        case .m3uLocal: return "Local M3U File"
        case .directStream: return "Direct Stream"
        }
    }
    
    public var shortName: String {
        switch self {
        case .stalkerhek: return "Stalker / Local"
        case .xtream: return "Xtream Codes"
        case .m3uURL: return "M3U URL"
        case .m3uLocal: return "Local File"
        case .directStream: return "Direct Stream"
        }
    }
    
    public var iconName: String {
        switch self {
        case .stalkerhek: return "antenna.radiowaves.left.and.right"
        case .xtream: return "bolt.horizontal.fill"
        case .m3uURL: return "globe"
        case .m3uLocal: return "doc.fill"
        case .directStream: return "play.tv.fill"
        }
    }
}

public struct Provider: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var type: ProviderType
    public var url: String
    public var username: String?
    public var password: String?
    public var epgURL: String?
    public var userAgent: String?
    public var httpReferer: String?
    public var isEnabled: Bool
    public var lastUpdated: Date?
    
    public init(
        id: UUID = UUID(),
        name: String,
        type: ProviderType,
        url: String,
        username: String? = nil,
        password: String? = nil,
        epgURL: String? = nil,
        userAgent: String? = nil,
        httpReferer: String? = nil,
        isEnabled: Bool = true,
        lastUpdated: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.url = url
        self.username = username
        self.password = password
        self.epgURL = epgURL
        self.userAgent = userAgent
        self.httpReferer = httpReferer
        self.isEnabled = isEnabled
        self.lastUpdated = lastUpdated
    }
    
    public static let defaultFreeTV = Provider(
        name: "Free-TV (Public)",
        type: .m3uURL,
        url: "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8",
        isEnabled: true
    )
}

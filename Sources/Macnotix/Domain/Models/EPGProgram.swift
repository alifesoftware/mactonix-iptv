import Foundation

public struct EPGProgram: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public let channelTvgId: String
    public let title: String
    public let showDescription: String?
    public let startTime: Date
    public let endTime: Date
    
    public init(
        id: UUID = UUID(),
        channelTvgId: String,
        title: String,
        showDescription: String? = nil,
        startTime: Date,
        endTime: Date
    ) {
        self.id = id
        self.channelTvgId = channelTvgId
        self.title = title
        self.showDescription = showDescription
        self.startTime = startTime
        self.endTime = endTime
    }
    
    public var isLiveNow: Bool {
        let now = Date()
        return startTime <= now && now <= endTime
    }
    
    public var progress: Double {
        let now = Date()
        guard isLiveNow else {
            return now > endTime ? 1.0 : 0.0
        }
        let total = endTime.timeIntervalSince(startTime)
        guard total > 0 else { return 0.0 }
        let elapsed = now.timeIntervalSince(startTime)
        return min(max(elapsed / total, 0.0), 1.0)
    }
    
    public var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}

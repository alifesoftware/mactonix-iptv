import Foundation

public struct StreamTelemetry: Sendable, Hashable {
    public var videoBitrateKbps: Double
    public var audioBitrateKbps: Double
    public var resolution: String
    public var fps: Double
    public var videoCodec: String
    public var audioCodec: String
    public var audioChannels: String
    public var sampleRateKhz: Double
    public var bufferDurationSecs: Double
    public var droppedFrames: Int
    public var engineName: String
    public var bitrateHistory: [Double]
    
    public init(
        videoBitrateKbps: Double = 0.0,
        audioBitrateKbps: Double = 0.0,
        resolution: String = "Unknown",
        fps: Double = 0.0,
        videoCodec: String = "Auto (H.264 / HEVC)",
        audioCodec: String = "AAC",
        audioChannels: String = "Stereo 2.0",
        sampleRateKhz: Double = 48.0,
        bufferDurationSecs: Double = 0.0,
        droppedFrames: Int = 0,
        engineName: String = "AVFoundation Hardware Engine",
        bitrateHistory: [Double] = []
    ) {
        self.videoBitrateKbps = videoBitrateKbps
        self.audioBitrateKbps = audioBitrateKbps
        self.resolution = resolution
        self.fps = fps
        self.videoCodec = videoCodec
        self.audioCodec = audioCodec
        self.audioChannels = audioChannels
        self.sampleRateKhz = sampleRateKhz
        self.bufferDurationSecs = bufferDurationSecs
        self.droppedFrames = droppedFrames
        self.engineName = engineName
        self.bitrateHistory = bitrateHistory
    }
}

import SwiftUI

public struct StreamTelemetryHUD: View {
    public let telemetry: StreamTelemetry
    public let onClose: () -> Void
    
    public init(telemetry: StreamTelemetry, onClose: @escaping () -> Void) {
        self.telemetry = telemetry
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Label("Stream Inspector", systemImage: "waveform.path.ecg")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }
            
            // Sparkline Bitrate Graph
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Bitrate")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1f Mbps", telemetry.videoBitrateKbps / 1000.0))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.cyan)
                }
                
                // Sparkline Bar Chart
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0..<max(telemetry.bitrateHistory.count, 1), id: \.self) { i in
                        let val = i < telemetry.bitrateHistory.count ? telemetry.bitrateHistory[i] : 0.0
                        let maxVal = max(telemetry.bitrateHistory.max() ?? 1000.0, 1000.0)
                        let height = CGFloat(val / maxVal) * 32.0
                        
                        RoundedRectangle(cornerRadius: 1)
                            .fill(LinearGradient(colors: [.cyan, .indigo], startPoint: .top, endPoint: .bottom))
                            .frame(width: 4, height: max(height, 3))
                    }
                }
                .frame(height: 36)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(4)
                .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.3)))
            }
            
            Divider()
            
            // Telemetry Matrix
            VStack(spacing: 8) {
                telemetryRow(title: "Resolution", value: telemetry.resolution)
                telemetryRow(title: "Frame Rate", value: String(format: "%.1f fps", telemetry.fps))
                telemetryRow(title: "Video Codec", value: telemetry.videoCodec)
                telemetryRow(title: "Audio Codec", value: "\(telemetry.audioCodec) (\(telemetry.audioChannels))")
                telemetryRow(title: "Buffer Length", value: String(format: "%.1fs", telemetry.bufferDurationSecs))
                telemetryRow(title: "Dropped Frames", value: "\(telemetry.droppedFrames)")
                telemetryRow(title: "Decoder Engine", value: telemetry.engineName)
            }
        }
        .padding(14)
        .frame(width: 310)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.4), radius: 16, y: 6)
    }
    
    @ViewBuilder
    private func telemetryRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }
}

import SwiftUI

public struct SettingsView: View {
    @State private var userAgent: String = StorageManager.shared.getUserAgent()
    @State private var httpReferer: String = StorageManager.shared.getHttpReferer()
    @State private var isClearingCache: Bool = false
    @State private var cacheClearedMessage: String?
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Preferences")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
            }
            .padding(16)
            .background(.ultraThinMaterial)
            
            Divider()
            
            Form {
                Section("Network & Streaming Headers") {
                    TextField("Default User-Agent", text: $userAgent)
                        .onChange(of: userAgent) { _, newVal in
                            StorageManager.shared.setUserAgent(newVal)
                        }
                    
                    TextField("HTTP Referer", text: $httpReferer)
                        .onChange(of: httpReferer) { _, newVal in
                            StorageManager.shared.setHttpReferer(newVal)
                        }
                }
                
                Section("Decoder Engine & Acceleration") {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Apple Silicon Hardware Engine")
                                .font(.system(size: 13, weight: .medium))
                            Text("Uses Apple VideoToolbox & AVFoundation hardware decoders for zero battery drain.")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Section("Storage & Cache") {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Channel Logo & Poster Cache")
                                .font(.system(size: 13, weight: .medium))
                            Text("Cached in ~/Library/Caches/Macnotix/Logos")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: clearCache) {
                            if isClearingCache {
                                ProgressView().scaleEffect(0.7)
                            } else {
                                Text("Clear Cache")
                            }
                        }
                    }
                    
                    if let msg = cacheClearedMessage {
                        Text(msg)
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }
            }
            .formStyle(.grouped)
            .padding(10)
        }
    }
    
    private func clearCache() {
        isClearingCache = true
        Task {
            await ImageCacheActor.shared.clearCache()
            await MainActor.run {
                self.isClearingCache = false
                self.cacheClearedMessage = "Cache successfully cleared!"
            }
        }
    }
}

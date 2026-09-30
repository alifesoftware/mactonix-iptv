import SwiftUI

public struct AddProviderSheet: View {
    @ObservedObject public var appVM: AppViewModel
    public var editingProvider: Provider?
    public let onDismiss: () -> Void
    
    @State private var name: String = ""
    @State private var type: ProviderType = .stalkerhek
    @State private var url: String = "http://localhost:4600"
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var epgURL: String = ""
    @State private var userAgent: String = ""
    @State private var isTesting: Bool = false
    @State private var testResult: String?
    @State private var isTestSuccessful: Bool = false
    
    public init(
        appVM: AppViewModel,
        editingProvider: Provider? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.appVM = appVM
        self.editingProvider = editingProvider
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(editingProvider == nil ? "Add IPTV Provider" : "Edit Provider")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("Configure Stalkerhek proxy, Xtream account, or M3U playlist")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Custom Segmented Tab Bar
            HStack(spacing: 6) {
                ForEach(ProviderType.allCases, id: \.self) { t in
                    Button(action: {
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75)) {
                            type = t
                            handleTypeChange(t)
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: t.iconName)
                                .font(.system(size: 12))
                            Text(t.shortName)
                                .font(.system(size: 12, weight: type == t ? .bold : .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(type == t ? Color.cyan : Color.white.opacity(0.06))
                        )
                        .foregroundColor(type == t ? .black : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 6)
            
            // Form Content
            Form {
                Section("General Information") {
                    TextField("Provider Name", text: $name)
                    
                    if type == .m3uLocal {
                        HStack {
                            TextField("File Path", text: $url)
                            Button("Browse...") {
                                chooseLocalFile()
                            }
                        }
                    } else {
                        TextField(type == .stalkerhek ? "Local Proxy URL (e.g. http://localhost:4600)" : "Server / Playlist URL", text: $url)
                    }
                }
                
                // Xtream Credentials
                if type == .xtream {
                    Section("Xtream Authentication") {
                        TextField("Username", text: $username)
                        SecureField("Password", text: $password)
                    }
                }
                
                // Advanced Section
                Section("Advanced (Optional)") {
                    TextField("EPG XMLTV URL (Optional)", text: $epgURL)
                    TextField("Custom User-Agent", text: $userAgent)
                }
                
                // Test Connection Feedback
                if let result = testResult {
                    HStack(spacing: 8) {
                        Image(systemName: isTestSuccessful ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isTestSuccessful ? .green : .red)
                        Text(result)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(isTestSuccessful ? .green : .red)
                    }
                    .padding(.vertical, 2)
                }
            }
            .formStyle(.grouped)
            .padding(.horizontal, 10)
            
            Divider()
            
            // Footer Action Buttons
            HStack {
                Button(action: { Task { await testConnection() } }) {
                    if isTesting {
                        HStack(spacing: 6) {
                            ProgressView().scaleEffect(0.7)
                            Text("Testing...")
                        }
                    } else {
                        Label("Test Connection", systemImage: "network")
                    }
                }
                .disabled(isTesting || url.isEmpty)
                
                Spacer()
                
                Button("Cancel", action: onDismiss)
                
                Button(editingProvider == nil ? "Save & Connect" : "Save Changes") {
                    saveProvider()
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .disabled(name.isEmpty || url.isEmpty)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(.ultraThinMaterial)
        }
        .resizableSheet(minWidth: 540, idealWidth: 640, minHeight: 460, idealHeight: 560)
        .onAppear {
            if let p = editingProvider {
                self.name = p.name
                self.type = p.type
                self.url = p.url
                self.username = p.username ?? ""
                self.password = p.password ?? ""
                self.epgURL = p.epgURL ?? ""
                self.userAgent = p.userAgent ?? ""
            }
        }
    }
    
    private func handleTypeChange(_ newType: ProviderType) {
        if editingProvider == nil {
            switch newType {
            case .stalkerhek:
                url = "http://localhost:4600"
                name = "Stalkerhek (Local)"
            case .xtream:
                url = "http://"
                name = "My Xtream Provider"
            case .m3uURL:
                url = "https://"
                name = "My Playlist"
            case .m3uLocal:
                url = ""
                name = "Local Playlist"
            case .directStream:
                url = "http://"
                name = "Direct Stream"
            }
        }
    }
    
    private func testConnection() async {
        isTesting = true
        testResult = nil
        
        let tempProvider = Provider(
            name: name,
            type: type,
            url: url,
            username: username.isEmpty ? nil : username,
            password: password.isEmpty ? nil : password,
            userAgent: userAgent.isEmpty ? nil : userAgent
        )
        let adapter = ProviderAdapterFactory.makeAdapter(for: tempProvider)
        
        do {
            let ok = try await adapter.testConnection()
            await MainActor.run {
                self.isTesting = false
                self.isTestSuccessful = ok
                self.testResult = ok ? "Connection Successful!" : "Server responded with an error."
            }
        } catch {
            await MainActor.run {
                self.isTesting = false
                self.isTestSuccessful = false
                self.testResult = "Failed: \(error.localizedDescription)"
            }
        }
    }
    
    private func saveProvider() {
        if let existing = editingProvider {
            var updated = existing
            updated.name = name
            updated.type = type
            updated.url = url
            updated.username = username.isEmpty ? nil : username
            updated.password = password.isEmpty ? nil : password
            updated.epgURL = epgURL.isEmpty ? nil : epgURL
            updated.userAgent = userAgent.isEmpty ? nil : userAgent
            appVM.updateProvider(updated)
        } else {
            let newP = Provider(
                name: name,
                type: type,
                url: url,
                username: username.isEmpty ? nil : username,
                password: password.isEmpty ? nil : password,
                epgURL: epgURL.isEmpty ? nil : epgURL,
                userAgent: userAgent.isEmpty ? nil : userAgent
            )
            appVM.addProvider(newP)
        }
        onDismiss()
    }
    
    private func chooseLocalFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.init(filenameExtension: "m3u")!, .init(filenameExtension: "m3u8")!, .text]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        if panel.runModal() == .OK, let selected = panel.url {
            self.url = selected.path
            if name.isEmpty {
                self.name = selected.deletingPathExtension().lastPathComponent
            }
        }
    }
}

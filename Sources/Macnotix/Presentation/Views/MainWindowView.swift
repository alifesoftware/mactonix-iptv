import SwiftUI
import AppKit

public struct MainWindowView: View {
    @ObservedObject public var appVM: AppViewModel
    @StateObject private var catalogVM = CatalogViewModel()
    @StateObject private var playerVM = PlayerViewModel()
    
    public init(appVM: AppViewModel) {
        self.appVM = appVM
    }
    
    public var body: some View {
        NavigationSplitView {
            if !appVM.isTheaterMode {
                SidebarView(appVM: appVM)
                    .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 300)
            }
        } content: {
            if !appVM.isTheaterMode {
                SwiftUI.Group {
                    switch appVM.selectedSection {
                    case .liveTV:
                        CatalogGridView(
                            appVM: appVM,
                            catalogVM: catalogVM,
                            playerVM: playerVM,
                            onlyFavorites: false
                        )
                    case .movies:
                        MovieCatalogView(
                            appVM: appVM,
                            catalogVM: catalogVM,
                            playerVM: playerVM
                        )
                    case .series:
                        SeriesCatalogView(
                            appVM: appVM,
                            catalogVM: catalogVM,
                            playerVM: playerVM
                        )
                    case .favorites:
                        CatalogGridView(
                            appVM: appVM,
                            catalogVM: catalogVM,
                            playerVM: playerVM,
                            onlyFavorites: true
                        )
                    case .providers:
                        ProviderManagerView(appVM: appVM)
                    case .settings:
                        SettingsView()
                    }
                }
                .navigationSplitViewColumnWidth(min: 280, ideal: 350, max: 500)
            }
        } detail: {
            VideoPlayerContainerView(
                playerVM: playerVM,
                appVM: appVM,
                channels: catalogVM.filteredChannels(
                    from: appVM.catalog.channels,
                    in: appVM.selectedGroup,
                    favorites: appVM.favorites,
                    onlyFavorites: appVM.selectedSection == .favorites
                )
            )
            .frame(minWidth: 400, idealWidth: 700, maxWidth: .infinity, minHeight: 300, idealHeight: 600, maxHeight: .infinity)
        }
        .navigationTitle(appVM.activeProvider?.name ?? "Macnotix IPTV")
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                // Refresh Provider
                Button(action: {
                    Task { await appVM.reloadActiveProvider() }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh Active Provider (⌘R)")
                
                // Stream Inspector (F2 / Cmd+I)
                Button(action: {
                    appVM.isStreamInspectorPresented.toggle()
                }) {
                    Image(systemName: "waveform.path.ecg")
                }
                .help("Stream Inspector (⌘I / F2)")
                
                // Theater Mode
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        appVM.isTheaterMode.toggle()
                    }
                }) {
                    Image(systemName: appVM.isTheaterMode ? "sidebar.left" : "rectangle.inset.filled.and.cursorarrow")
                }
                .help("Toggle Theater Mode (⌘⌥T)")
            }
        }
        .background(WindowConfigurator())
        // Keyboard Shortcuts
        .background(
            KeyboardShortcutsHandler(
                playerVM: playerVM,
                appVM: appVM,
                channels: catalogVM.filteredChannels(
                    from: appVM.catalog.channels,
                    in: appVM.selectedGroup,
                    favorites: appVM.favorites,
                    onlyFavorites: appVM.selectedSection == .favorites
                )
            )
        )
        // Sheets
        .sheet(isPresented: $appVM.isAddProviderSheetPresented) {
            AddProviderSheet(appVM: appVM) {
                appVM.isAddProviderSheetPresented = false
            }
        }
        .sheet(isPresented: $appVM.isShortcutsHelpPresented) {
            ShortcutsHelpSheet {
                appVM.isShortcutsHelpPresented = false
            }
        }
    }
}

private struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.styleMask.insert(.resizable)
                window.styleMask.insert(.miniaturizable)
                window.minSize = NSSize(width: 900, height: 600)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

private struct KeyboardShortcutsHandler: View {
    @ObservedObject var playerVM: PlayerViewModel
    @ObservedObject var appVM: AppViewModel
    let channels: [Channel]
    
    var body: some View {
        EmptyView()
            .focusable()
            .onKeyPress(.space) {
                playerVM.engine.togglePlayPause()
                return .handled
            }
            .onKeyPress(.upArrow) {
                playerVM.previousChannel(in: channels)
                return .handled
            }
            .onKeyPress(.downArrow) {
                playerVM.nextChannel(in: channels)
                return .handled
            }
    }
}

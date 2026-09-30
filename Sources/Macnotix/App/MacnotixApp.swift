import SwiftUI

@main
public struct MacnotixApp: App {
    @StateObject private var environment = AppEnvironment.shared
    
    public init() {}
    
    public var body: some Scene {
        WindowGroup {
            MainWindowView(appVM: environment.appViewModel)
                .frame(
                    minWidth: 960,
                    idealWidth: 1280,
                    maxWidth: .infinity,
                    minHeight: 600,
                    idealHeight: 800,
                    maxHeight: .infinity
                )
                .preferredColorScheme(.dark)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add IPTV Provider...") {
                    environment.appViewModel.isAddProviderSheetPresented = true
                }
                .keyboardShortcut("n", modifiers: [.command])
                
                Button("Refresh Active Provider") {
                    Task {
                        await environment.appViewModel.reloadActiveProvider()
                    }
                }
                .keyboardShortcut("r", modifiers: [.command])
            }
            
            CommandMenu("View") {
                Button("Toggle Theater Mode") {
                    withAnimation {
                        environment.appViewModel.isTheaterMode.toggle()
                    }
                }
                .keyboardShortcut("t", modifiers: [.command, .option])
                
                Button("Stream Inspector") {
                    environment.appViewModel.isStreamInspectorPresented.toggle()
                }
                .keyboardShortcut("i", modifiers: [.command])
            }
            
            CommandGroup(replacing: .help) {
                Button("Keyboard Shortcuts Help") {
                    environment.appViewModel.isShortcutsHelpPresented = true
                }
                .keyboardShortcut("k", modifiers: [.command])
            }
        }
        
        // macOS Status Bar Menu Extra
        MenuBarExtra("Macnotix", systemImage: "tv") {
            MenuBarExtraView(
                appVM: environment.appViewModel,
                playerVM: PlayerViewModel()
            )
        }
        .menuBarExtraStyle(.window)
    }
}

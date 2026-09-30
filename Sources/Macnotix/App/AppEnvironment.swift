import Foundation

@MainActor
public final class AppEnvironment: ObservableObject {
    public static let shared = AppEnvironment()
    
    public let appViewModel: AppViewModel
    public let storageManager: StorageManager
    public let sleepInhibitor: SleepInhibitorService
    public let nowPlaying: NowPlayingService
    
    public init() {
        self.storageManager = StorageManager.shared
        self.sleepInhibitor = SleepInhibitorService.shared
        self.nowPlaying = NowPlayingService.shared
        self.appViewModel = AppViewModel()
    }
}

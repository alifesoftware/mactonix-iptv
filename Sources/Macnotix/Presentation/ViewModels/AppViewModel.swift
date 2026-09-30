import Foundation
import Combine

public enum NavigationSection: String, CaseIterable, Identifiable, Sendable {
    case liveTV = "Live TV"
    case movies = "Movies"
    case series = "TV Series"
    case favorites = "Favorites"
    case providers = "Providers"
    case settings = "Settings"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .liveTV: return "tv"
        case .movies: return "film"
        case .series: return "play.rectangle.on.rectangle"
        case .favorites: return "star.fill"
        case .providers: return "antenna.radiowaves.left.and.right"
        case .settings: return "gearshape"
        }
    }
}

@MainActor
public final class AppViewModel: ObservableObject {
    @Published public var selectedSection: NavigationSection = .liveTV
    @Published public var selectedGroup: Group?
    
    @Published public var providers: [Provider] = []
    @Published public var activeProvider: Provider?
    
    @Published public var catalog: ProviderCatalog = ProviderCatalog()
    @Published public var favorites: Set<String> = []
    
    @Published public var isLoading: Bool = false
    @Published public var statusMessage: String?
    @Published public var errorMessage: String?
    
    @Published public var isAddProviderSheetPresented: Bool = false
    @Published public var isShortcutsHelpPresented: Bool = false
    @Published public var isStreamInspectorPresented: Bool = false
    @Published public var isTheaterMode: Bool = false
    
    private let storage = StorageManager.shared
    
    public init() {
        self.providers = storage.loadProviders()
        self.favorites = storage.loadFavorites()
        
        if let activeId = storage.getActiveProviderId(),
           let match = providers.first(where: { $0.id == activeId }) {
            self.activeProvider = match
        } else {
            self.activeProvider = providers.first
        }
        
        Task {
            await reloadActiveProvider()
        }
    }
    
    public func selectProvider(_ provider: Provider) {
        self.activeProvider = provider
        storage.setActiveProviderId(provider.id)
        Task {
            await reloadActiveProvider()
        }
    }
    
    public func reloadActiveProvider() async {
        guard let provider = activeProvider else {
            self.catalog = ProviderCatalog()
            return
        }
        
        self.isLoading = true
        self.statusMessage = "Loading \(provider.name)..."
        self.errorMessage = nil
        
        let adapter = ProviderAdapterFactory.makeAdapter(for: provider)
        
        do {
            let cat = try await adapter.loadCatalog()
            self.catalog = cat
            self.statusMessage = nil
            self.isLoading = false
            
            // Auto select first group if current selectedGroup does not exist in new catalog
            if let first = cat.liveGroups.first {
                self.selectedGroup = first
            }
        } catch {
            self.isLoading = false
            self.statusMessage = nil
            self.errorMessage = "Failed to load provider: \(error.localizedDescription)"
        }
    }
    
    public func addProvider(_ newProvider: Provider) {
        providers.append(newProvider)
        storage.saveProviders(providers)
        selectProvider(newProvider)
    }
    
    public func updateProvider(_ updated: Provider) {
        if let idx = providers.firstIndex(where: { $0.id == updated.id }) {
            providers[idx] = updated
            storage.saveProviders(providers)
            if activeProvider?.id == updated.id {
                self.activeProvider = updated
                Task {
                    await reloadActiveProvider()
                }
            }
        }
    }
    
    public func deleteProvider(_ provider: Provider) {
        providers.removeAll(where: { $0.id == provider.id })
        storage.saveProviders(providers)
        if activeProvider?.id == provider.id {
            selectProvider(providers.first ?? Provider.defaultFreeTV)
        }
    }
    
    public func toggleFavorite(id: String) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        storage.saveFavorites(favorites)
    }
    
    public func isFavorite(id: String) -> Bool {
        favorites.contains(id)
    }
}

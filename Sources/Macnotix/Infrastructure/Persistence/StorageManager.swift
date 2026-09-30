import Foundation

public final class StorageManager: @unchecked Sendable {
    public static let shared = StorageManager()
    
    private let defaults = UserDefaults.standard
    private let providersKey = "macnotix_providers"
    private let activeProviderKey = "macnotix_active_provider"
    private let favoritesKey = "macnotix_favorites"
    private let userAgentKey = "macnotix_user_agent"
    private let refererKey = "macnotix_referer"
    
    public init() {}
    
    public func loadProviders() -> [Provider] {
        if let data = defaults.data(forKey: providersKey),
           let list = try? JSONDecoder().decode([Provider].self, from: data),
           !list.isEmpty {
            return list
        }
        // Default initial providers
        let initial = [
            Provider(
                name: "Stalkerhek (Local Proxy)",
                type: .stalkerhek,
                url: "http://localhost:4600",
                isEnabled: true
            ),
            Provider.defaultFreeTV
        ]
        saveProviders(initial)
        return initial
    }
    
    public func saveProviders(_ providers: [Provider]) {
        if let data = try? JSONEncoder().encode(providers) {
            defaults.set(data, forKey: providersKey)
        }
    }
    
    public func getActiveProviderId() -> UUID? {
        if let str = defaults.string(forKey: activeProviderKey) {
            return UUID(uuidString: str)
        }
        return nil
    }
    
    public func setActiveProviderId(_ id: UUID?) {
        if let id = id {
            defaults.set(id.uuidString, forKey: activeProviderKey)
        } else {
            defaults.removeObject(forKey: activeProviderKey)
        }
    }
    
    public func loadFavorites() -> Set<String> {
        let list = defaults.stringArray(forKey: favoritesKey) ?? []
        return Set(list)
    }
    
    public func saveFavorites(_ favorites: Set<String>) {
        defaults.set(Array(favorites), forKey: favoritesKey)
    }
    
    public func getUserAgent() -> String {
        defaults.string(forKey: userAgentKey) ?? "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15"
    }
    
    public func setUserAgent(_ val: String) {
        defaults.set(val, forKey: userAgentKey)
    }
    
    public func getHttpReferer() -> String {
        defaults.string(forKey: refererKey) ?? ""
    }
    
    public func setHttpReferer(_ val: String) {
        defaults.set(val, forKey: refererKey)
    }
}

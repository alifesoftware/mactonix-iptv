import Foundation
import Combine

public enum CatalogLayoutMode: String, CaseIterable, Sendable {
    case grid = "Grid"
    case list = "List"
    
    public var iconName: String {
        switch self {
        case .grid: return "square.grid.2x2"
        case .list: return "list.bullet"
        }
    }
}

@MainActor
public final class CatalogViewModel: ObservableObject {
    @Published public var searchQuery: String = ""
    @Published public var layoutMode: CatalogLayoutMode = .grid
    @Published public var selectedCountryCode: String?
    
    public init() {}
    
    public func filteredChannels(from channels: [Channel], in selectedGroup: Group?, favorites: Set<String>, onlyFavorites: Bool = false) -> [Channel] {
        var list = channels
        
        if onlyFavorites {
            list = list.filter { favorites.contains($0.streamURL.absoluteString) || favorites.contains($0.name) }
        } else if let group = selectedGroup {
            list = list.filter { $0.groupTitle == group.name }
        }
        
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            list = list.filter {
                $0.name.lowercased().contains(q) ||
                ($0.title?.lowercased().contains(q) ?? false) ||
                ($0.groupTitle?.lowercased().contains(q) ?? false)
            }
        }
        
        return list
    }
    
    public func filteredMovies(from movies: [Movie], in selectedGroup: Group?) -> [Movie] {
        var list = movies
        if let group = selectedGroup {
            list = list.filter { $0.groupTitle == group.name }
        }
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            list = list.filter {
                $0.name.lowercased().contains(q) ||
                ($0.genre?.lowercased().contains(q) ?? false)
            }
        }
        return list
    }
    
    public func filteredSeries(from series: [Serie], in selectedGroup: Group?) -> [Serie] {
        var list = series
        if let group = selectedGroup {
            list = list.filter { $0.groupTitle == group.name }
        }
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            list = list.filter {
                $0.name.lowercased().contains(q) ||
                ($0.genre?.lowercased().contains(q) ?? false)
            }
        }
        return list
    }
}

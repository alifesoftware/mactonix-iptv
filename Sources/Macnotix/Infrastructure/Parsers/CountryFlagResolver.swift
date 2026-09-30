import Foundation

public struct CountryInfo: Codable, Sendable {
    public let code: String
    public let name: String
    public let flag: String
}

public final class CountryFlagResolver: @unchecked Sendable {
    public static let shared = CountryFlagResolver()
    
    private var countryMap: [String: CountryInfo] = [:]
    
    public init() {
        loadCountries()
    }
    
    private func loadCountries() {
        if let url = Bundle.module.url(forResource: "Countries", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let list = try? JSONDecoder().decode([CountryInfo].self, from: data) {
            for item in list {
                countryMap[item.name.lowercased()] = item
                countryMap[item.code.lowercased()] = item
            }
        }
    }
    
    public func resolve(for groupOrCountryName: String) -> (code: String, flag: String)? {
        let clean = groupOrCountryName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if let exact = countryMap[clean] {
            return (exact.code, exact.flag)
        }
        
        // Match substrings like "UK: BBC" or "US | News"
        for (key, info) in countryMap {
            if clean.contains(key) || clean.hasPrefix(key + " ") || clean.hasPrefix(key + ":") {
                return (info.code, info.flag)
            }
        }
        
        return nil
    }
}

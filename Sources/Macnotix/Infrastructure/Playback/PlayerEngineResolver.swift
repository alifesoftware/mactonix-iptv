import Foundation

public struct ProviderAdapterFactory {
    public static func makeAdapter(for provider: Provider) -> any ProviderSource {
        switch provider.type {
        case .stalkerhek:
            return StalkerhekAdapter(provider: provider)
        case .xtream:
            return XtreamCodesAdapter(provider: provider)
        case .m3uURL, .m3uLocal:
            return M3UPlaylistAdapter(provider: provider)
        case .directStream:
            return DirectStreamAdapter(provider: provider)
        }
    }
}

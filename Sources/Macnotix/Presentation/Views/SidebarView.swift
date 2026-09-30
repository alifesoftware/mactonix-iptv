import SwiftUI

public struct SidebarView: View {
    @ObservedObject public var appVM: AppViewModel
    
    public init(appVM: AppViewModel) {
        self.appVM = appVM
    }
    
    public var body: some View {
        List {
            // Main Navigation Sections
            Section("Browse") {
                NavigationRow(
                    title: "Live TV",
                    icon: "tv",
                    badge: "\(appVM.catalog.channels.count)",
                    isSelected: appVM.selectedSection == .liveTV
                ) {
                    appVM.selectedSection = .liveTV
                }
                
                NavigationRow(
                    title: "Movies",
                    icon: "film",
                    badge: "\(appVM.catalog.movies.count)",
                    isSelected: appVM.selectedSection == .movies
                ) {
                    appVM.selectedSection = .movies
                }
                
                NavigationRow(
                    title: "TV Series",
                    icon: "play.rectangle.on.rectangle",
                    badge: "\(appVM.catalog.series.count)",
                    isSelected: appVM.selectedSection == .series
                ) {
                    appVM.selectedSection = .series
                }
                
                NavigationRow(
                    title: "Favorites",
                    icon: "star.fill",
                    badge: "\(appVM.favorites.count)",
                    isSelected: appVM.selectedSection == .favorites
                ) {
                    appVM.selectedSection = .favorites
                }
            }
            
            // Categories / Groups based on current section
            if appVM.selectedSection == .liveTV && !appVM.catalog.liveGroups.isEmpty {
                Section("Live Categories (\(appVM.catalog.liveGroups.count))") {
                    ForEach(appVM.catalog.liveGroups) { group in
                        HStack(spacing: 8) {
                            if let flag = group.flagEmoji {
                                Text(flag)
                                    .font(.system(size: 14))
                            } else {
                                Image(systemName: "tv")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(group.name)
                                .font(.system(size: 12))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Text("\(group.channelCount)")
                                .font(.system(size: 10, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(appVM.selectedGroup?.id == group.id ? Color.cyan.opacity(0.18) : Color.clear)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appVM.selectedGroup = group
                        }
                    }
                }
            } else if appVM.selectedSection == .movies && !appVM.catalog.movieGroups.isEmpty {
                Section("Movie Genres (\(appVM.catalog.movieGroups.count))") {
                    ForEach(appVM.catalog.movieGroups) { group in
                        HStack {
                            Text(group.name)
                                .font(.system(size: 12))
                                .lineLimit(1)
                            Spacer()
                            Text("\(group.channelCount)")
                                .font(.system(size: 10, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(appVM.selectedGroup?.id == group.id ? Color.cyan.opacity(0.18) : Color.clear)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            appVM.selectedGroup = group
                        }
                    }
                }
            }
            
            // Manage & Providers Section
            Section("Settings") {
                NavigationRow(
                    title: "Providers",
                    icon: "antenna.radiowaves.left.and.right",
                    badge: "\(appVM.providers.count)",
                    isSelected: appVM.selectedSection == .providers
                ) {
                    appVM.selectedSection = .providers
                }
                
                NavigationRow(
                    title: "Preferences",
                    icon: "gearshape",
                    badge: nil,
                    isSelected: appVM.selectedSection == .settings
                ) {
                    appVM.selectedSection = .settings
                }
            }
        }
        .listStyle(.sidebar)
        .safeAreaInset(edge: .bottom) {
            // Active Provider Switcher Button at bottom
            if let active = appVM.activeProvider {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(active.name)
                            .font(.system(size: 11, weight: .bold))
                            .lineLimit(1)
                        Text(active.type.displayName)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task { await appVM.reloadActiveProvider() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Reload Provider (⌘R)")
                }
                .padding(10)
                .background(.ultraThinMaterial)
                .overlay(
                    Rectangle().frame(height: 1).foregroundColor(Color.white.opacity(0.1)),
                    alignment: .top
                )
            }
        }
    }
}

private struct NavigationRow: View {
    let title: String
    let icon: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .cyan : .secondary)
                    .frame(width: 18)
                
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .cyan : .primary)
                
                Spacer()
                
                if let badge = badge, badge != "0" {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(isSelected ? Color.cyan.opacity(0.25) : Color.secondary.opacity(0.2)))
                        .foregroundColor(isSelected ? .cyan : .secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

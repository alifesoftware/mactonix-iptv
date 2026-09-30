import SwiftUI

public struct ProviderManagerView: View {
    @ObservedObject public var appVM: AppViewModel
    @State private var editingProvider: Provider?
    @State private var hoveredProviderId: UUID?
    
    public init(appVM: AppViewModel) {
        self.appVM = appVM
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("IPTV Providers")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("\(appVM.providers.count) configured")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { appVM.isAddProviderSheetPresented = true }) {
                    Label("Add Provider", systemImage: "plus")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .controlSize(.small)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Cards ScrollView
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(appVM.providers) { provider in
                        ProviderCard(
                            provider: provider,
                            isActive: appVM.activeProvider?.id == provider.id,
                            isHovered: hoveredProviderId == provider.id,
                            onSelect: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    appVM.selectProvider(provider)
                                }
                            },
                            onEdit: { editingProvider = provider },
                            onDelete: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    appVM.deleteProvider(provider)
                                }
                            }
                        )
                        .onHover { isHovered in
                            hoveredProviderId = isHovered ? provider.id : nil
                        }
                    }
                }
                .padding(14)
            }
        }
        .sheet(item: $editingProvider) { p in
            AddProviderSheet(appVM: appVM, editingProvider: p) {
                editingProvider = nil
            }
        }
    }
}

private struct ProviderCard: View {
    let provider: Provider
    let isActive: Bool
    let isHovered: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Top Header: Icon + Name + Active Status Badge
            HStack(alignment: .center, spacing: 12) {
                // Icon Badge
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isActive ? Color.cyan.opacity(0.2) : Color.white.opacity(0.06))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: provider.type.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isActive ? .cyan : .secondary)
                }
                
                // Name & Type
                VStack(alignment: .leading, spacing: 2) {
                    Text(provider.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(provider.type.displayName)
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status Badge or Activation Indicator
                if isActive {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        Text("ACTIVE")
                            .font(.system(size: 9, weight: .black, design: .rounded))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.green.opacity(0.15)))
                }
            }
            
            // Server URL Pill
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                
                Text(provider.url)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 6).fill(Color.black.opacity(0.25)))
            
            Divider()
                .opacity(0.6)
            
            // Bottom Action Row
            HStack(spacing: 8) {
                if !isActive {
                    Button(action: onSelect) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle")
                            Text("Set Active")
                        }
                        .font(.system(size: 11, weight: .semibold))
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .tint(.cyan)
                } else {
                    Text("Currently connected")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Edit Button
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.white.opacity(0.06)))
                }
                .buttonStyle(.plain)
                .help("Edit Provider")
                
                // Delete Button
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.85))
                        .frame(width: 26, height: 26)
                        .background(Circle().fill(Color.red.opacity(0.1)))
                }
                .buttonStyle(.plain)
                .help("Delete Provider")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(
                    isActive ? Color.cyan.opacity(0.5) : (isHovered ? Color.white.opacity(0.2) : Color.white.opacity(0.08)),
                    lineWidth: isActive ? 1.5 : 1.0
                )
        )
        .shadow(color: isActive ? Color.cyan.opacity(0.15) : Color.black.opacity(0.1), radius: isActive ? 6 : 3, y: 2)
    }
}

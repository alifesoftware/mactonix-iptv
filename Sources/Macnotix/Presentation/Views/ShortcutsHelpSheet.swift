import SwiftUI

public struct ShortcutsHelpSheet: View {
    public let onDismiss: () -> Void
    
    public init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Label("Keyboard Shortcuts", systemImage: "keyboard")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .background(.ultraThinMaterial)
            
            Divider()
            
            VStack(spacing: 12) {
                shortcutRow(keys: ["Space"], description: "Play / Pause playback")
                shortcutRow(keys: ["▲", "▼"], description: "Next / Previous Channel")
                shortcutRow(keys: ["◄", "►"], description: "Seek backward / forward (VOD)")
                shortcutRow(keys: ["⌘", "F"], description: "Toggle Fullscreen")
                shortcutRow(keys: ["⌘", "⌥", "T"], description: "Toggle Theater Mode")
                shortcutRow(keys: ["⌘", "I", "or", "F2"], description: "Open Stream Telemetry Inspector")
                shortcutRow(keys: ["⌘", "R"], description: "Force Refresh Active Provider")
                shortcutRow(keys: ["⌘", "K"], description: "Open Keyboard Shortcuts Help")
            }
            .padding(20)
        }
        .resizableSheet(minWidth: 380, idealWidth: 440, minHeight: 340, idealHeight: 420)
    }
    
    @ViewBuilder
    private func shortcutRow(keys: [String], description: String) -> some View {
        HStack {
            Text(description)
                .font(.system(size: 13))
            Spacer()
            HStack(spacing: 4) {
                ForEach(keys, id: \.self) { k in
                    Text(k)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.secondary.opacity(0.2)))
                }
            }
        }
    }
}

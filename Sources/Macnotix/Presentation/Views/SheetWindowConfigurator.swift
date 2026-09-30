import SwiftUI
import AppKit

/// An NSViewRepresentable helper that configures the enclosing NSWindow or sheet NSPanel
/// to allow typical mouse edge/corner dragging and resizing.
public struct SheetWindowConfigurator: NSViewRepresentable {
    public let minWidth: CGFloat
    public let minHeight: CGFloat
    
    public init(minWidth: CGFloat = 500, minHeight: CGFloat = 400) {
        self.minWidth = minWidth
        self.minHeight = minHeight
    }
    
    public func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            configureWindow(for: view)
        }
        return view
    }
    
    public func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configureWindow(for: nsView)
        }
    }
    
    private func configureWindow(for view: NSView) {
        guard let window = view.window else { return }
        window.styleMask.insert(.resizable)
        window.minSize = NSSize(width: minWidth, height: minHeight)
        window.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        window.showsResizeIndicator = true
    }
}

public struct ResizableSheetModifier: ViewModifier {
    public let minWidth: CGFloat
    public let idealWidth: CGFloat
    public let minHeight: CGFloat
    public let idealHeight: CGFloat
    
    public init(minWidth: CGFloat, idealWidth: CGFloat, minHeight: CGFloat, idealHeight: CGFloat) {
        self.minWidth = minWidth
        self.idealWidth = idealWidth
        self.minHeight = minHeight
        self.idealHeight = idealHeight
    }
    
    public func body(content: Content) -> some View {
        content
            .frame(
                minWidth: minWidth,
                idealWidth: idealWidth,
                maxWidth: .infinity,
                minHeight: minHeight,
                idealHeight: idealHeight,
                maxHeight: .infinity
            )
            .background(SheetWindowConfigurator(minWidth: minWidth, minHeight: minHeight))
    }
}

public extension View {
    /// Applies resizable behavior to modal sheets with minimum, ideal, and unbounded maximum dimensions,
    /// enabling standard macOS mouse drag-resizing along all borders and corners.
    func resizableSheet(
        minWidth: CGFloat = 540,
        idealWidth: CGFloat = 640,
        minHeight: CGFloat = 460,
        idealHeight: CGFloat = 560
    ) -> some View {
        self.modifier(ResizableSheetModifier(
            minWidth: minWidth,
            idealWidth: idealWidth,
            minHeight: minHeight,
            idealHeight: idealHeight
        ))
    }
}

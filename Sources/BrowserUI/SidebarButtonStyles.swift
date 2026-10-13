import SwiftUI

/// Shared hover and press timing for sidebar controls, so rows, close buttons
/// and the toolbar all respond the same way.
enum SidebarHover {
    static let animation = Animation.easeOut(duration: 0.14)
    static let rowHoverFill = Color.primary.opacity(0.055)
    static let iconHoverFill = Color.primary.opacity(0.10)
    static let iconPressFill = Color.primary.opacity(0.17)
}

/// A small icon button that highlights on hover and darkens on press, like the
/// toolbar and close buttons in Arc and Safari.
struct SidebarIconButtonStyle: ButtonStyle {
    enum Shape {
        /// Close buttons on tab rows and pinned tabs.
        case circle
        /// Toolbar buttons in the sidebar's top and bottom bars.
        case roundedRectangle
    }

    var shape: Shape = .roundedRectangle

    func makeBody(configuration: Configuration) -> some View {
        SidebarIconButton(configuration: configuration, shape: shape)
    }
}

private struct SidebarIconButton: View {
    let configuration: ButtonStyleConfiguration
    let shape: SidebarIconButtonStyle.Shape

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isHovering = false

    var body: some View {
        configuration.label
            .foregroundStyle(foreground)
            .background { highlight.fill(fill) }
            .contentShape(highlight)
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.92 : 1)
            .onHover { isHovering = $0 }
            .animation(reduceMotion ? nil : SidebarHover.animation, value: isHovering)
            .animation(reduceMotion ? nil : SidebarHover.animation, value: configuration.isPressed)
    }

    private var highlight: AnyShape {
        switch shape {
        case .circle: AnyShape(Circle())
        case .roundedRectangle: AnyShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }

    private var fill: Color {
        guard isEnabled else { return .clear }
        if configuration.isPressed { return SidebarHover.iconPressFill }
        return isHovering ? SidebarHover.iconHoverFill : .clear
    }

    private var foreground: HierarchicalShapeStyle {
        guard isEnabled else { return .tertiary }
        return isHovering || configuration.isPressed ? .primary : .secondary
    }
}

/// A full-width sidebar row: a brief darkening while pressed, on top of the
/// row's own hover and selection background.
struct SidebarRowButtonStyle: ButtonStyle {
    var cornerRadius: CGFloat = 9

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.primary.opacity(configuration.isPressed ? 0.06 : 0))
                    .allowsHitTesting(false)
            }
    }
}

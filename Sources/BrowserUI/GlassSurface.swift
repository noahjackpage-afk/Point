import SwiftUI

/// Plain Liquid Glass is close to clear, so busy pages and the desktop show
/// straight through it. A layer of the window background under the glass keeps
/// its edges and highlights while letting the pane read as a surface.
enum BrowserGlassBacking {
    /// Floating panels over page content: the omnibox, menus, the overlay sidebar.
    static let floatingOpacity = 0.78
    /// Panes that sit beside the page, such as the pinned sidebar.
    static let paneOpacity = 0.62

    static func color(opacity: Double) -> Color {
        Color(nsColor: .windowBackgroundColor).opacity(opacity)
    }
}

struct BrowserGlassSurface: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        if reduceTransparency {
            content
                .background(Color(nsColor: .windowBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(.separator, lineWidth: 1)
                }
        } else if #available(macOS 26, *) {
            content
                .background(
                    BrowserGlassBacking.color(opacity: BrowserGlassBacking.floatingOpacity),
                    in: .rect(cornerRadius: cornerRadius)
                )
                .glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}

/// Tinted Liquid Glass, used where the surface should read as a pane of glass
/// over the desktop rather than an opaque panel.
struct BrowserTintedGlass: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let cornerRadius: CGFloat
    let tint: Color?
    let isInteractive: Bool
    let backingOpacity: Double
    /// False draws nothing, letting a surface behind show through, while keeping
    /// the same view so switching animates instead of swapping views.
    let showsGlass: Bool

    func body(content: Content) -> some View {
        if reduceTransparency {
            content
                .background(showsGlass ? Color(nsColor: .windowBackgroundColor) : .clear)
                .clipShape(shape)
                .overlay { shape.stroke(.separator.opacity(showsGlass ? 1 : 0), lineWidth: 1) }
        } else if #available(macOS 26, *) {
            content
                .background(
                    BrowserGlassBacking.color(opacity: showsGlass ? backingOpacity : 0),
                    in: shape
                )
                .glassEffect(showsGlass ? glass : .identity, in: shape)
        } else {
            content
                .background(.ultraThinMaterial)
                .clipShape(shape)
        }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    @available(macOS 26, *)
    private var glass: Glass {
        let base = isInteractive ? Glass.regular.interactive() : Glass.regular
        return tint.map { base.tint($0) } ?? base
    }
}

extension View {
    func browserGlassSurface(cornerRadius: CGFloat = 20) -> some View {
        modifier(BrowserGlassSurface(cornerRadius: cornerRadius))
    }

    func browserTintedGlass(
        cornerRadius: CGFloat = 0,
        tint: Color? = nil,
        isInteractive: Bool = false,
        backingOpacity: Double = BrowserGlassBacking.paneOpacity,
        showsGlass: Bool = true
    ) -> some View {
        modifier(
            BrowserTintedGlass(
                cornerRadius: cornerRadius,
                tint: tint,
                isInteractive: isInteractive,
                backingOpacity: backingOpacity,
                showsGlass: showsGlass
            )
        )
    }
}

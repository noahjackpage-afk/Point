import AppKit
import BrowserCore
import SwiftUI

/// Installed extensions. Installing from the store, options pages and side
/// panels all open in a browser window, so this works against the standard
/// window the person was most recently in.
struct ExtensionsSettingsPane: View {
    let windowModels: @MainActor () -> [BrowserWindowModel]

    @State private var model: BrowserWindowModel?

    var body: some View {
        Group {
            if let model {
                BrowserExtensionsSettingsView(model: model)
            } else {
                ContentUnavailableView(
                    BrowserLocalization.string("extensions_no_window"),
                    systemImage: BrowserSettingsSection.extensions.symbol,
                    description: Text(BrowserLocalization.string("extensions_no_window_detail"))
                )
            }
        }
        .onAppear {
            model = BrowserWindowModel.mostRecentStandardWindow(among: windowModels())
        }
    }
}

extension BrowserWindowModel {
    /// The non-private window highest in the window order, for app-wide panels.
    static func mostRecentStandardWindow(
        among models: [BrowserWindowModel]
    ) -> BrowserWindowModel? {
        let order = NSApp.orderedWindows
        func rank(_ model: BrowserWindowModel) -> Int {
            model.extensionHostWindow.flatMap { order.firstIndex(of: $0) } ?? .max
        }
        return models
            .filter { !$0.isPrivate }
            .min { rank($0) < rank($1) }
    }
}

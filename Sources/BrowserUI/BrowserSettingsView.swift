import AppKit
import BrowserCore
import SwiftUI

public enum BrowserSettingsSection: String, CaseIterable, Identifiable {
    case general
    case appearance
    case performance
    case extensions

    /// The Settings window remembers its last tab, and a browser window sets it
    /// before opening Settings on a particular page (e.g. "Manage Extensions").
    public static let selectionDefaultsKey = "BrowserSettingsSelectedSection"

    public var id: Self { self }

    var title: String {
        BrowserLocalization.string("settings_section_\(rawValue)")
    }

    var symbol: String {
        switch self {
        case .general: "gearshape"
        case .appearance: "paintpalette"
        case .performance: "memorychip"
        case .extensions: "puzzlepiece.extension"
        }
    }
}

/// The app's Settings window (⌘,), with one toolbar tab per section.
public struct BrowserSettingsView: View {
    private let windowModels: @MainActor () -> [BrowserWindowModel]

    @AppStorage(BrowserSettingsSection.selectionDefaultsKey)
    private var selection: BrowserSettingsSection = .general

    /// - Parameter windowModels: the open browser windows. Extensions are
    ///   managed against the one the person was most recently in.
    public init(windowModels: @escaping @MainActor () -> [BrowserWindowModel]) {
        self.windowModels = windowModels
    }

    public var body: some View {
        TabView(selection: $selection) {
            Tab(
                BrowserSettingsSection.general.title,
                systemImage: BrowserSettingsSection.general.symbol,
                value: .general
            ) {
                GeneralSettingsPane()
            }

            Tab(
                BrowserSettingsSection.appearance.title,
                systemImage: BrowserSettingsSection.appearance.symbol,
                value: .appearance
            ) {
                AppearanceSettingsPane()
            }

            Tab(
                BrowserSettingsSection.performance.title,
                systemImage: BrowserSettingsSection.performance.symbol,
                value: .performance
            ) {
                PerformanceSettingsPane()
            }

            Tab(
                BrowserSettingsSection.extensions.title,
                systemImage: BrowserSettingsSection.extensions.symbol,
                value: .extensions
            ) {
                ExtensionsSettingsPane(windowModels: windowModels)
            }
        }
        .frame(width: 620, height: 500)
    }
}

extension View {
    func settingsFormStyle() -> some View {
        formStyle(.grouped)
    }
}

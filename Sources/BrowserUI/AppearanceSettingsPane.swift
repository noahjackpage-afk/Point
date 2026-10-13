import BrowserCore
import SwiftUI

/// How panels look over full-screen windows.
struct AppearanceSettingsPane: View {
    var body: some View {
        Form {
            Section(BrowserLocalization.string("fullscreen_panels")) {
                Text(BrowserLocalization.string("fullscreen_panels_detail"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                FullScreenPanelBackdropPicker()
            }
        }
        .settingsFormStyle()
    }
}

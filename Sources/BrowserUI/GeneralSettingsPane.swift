import AppKit
import BrowserCore
import BrowserEngine
import SwiftUI

/// Ad blocking, default browser, updates and the welcome tour.
struct GeneralSettingsPane: View {
    @Bindable private var adBlock = AdBlockController.shared
    @Environment(\.dismiss) private var dismiss

    @State private var isDefaultBrowser = false
    @State private var isDefaultBrowserUpdateInProgress = false
    @State private var defaultBrowserError: String?
    @State private var isCheckingForUpdates = false
    @State private var updateCheckStatus: BrowserManualUpdate.CheckStatus?

    var body: some View {
        Form {
            Section(BrowserLocalization.string("adblock_section")) {
                Toggle(BrowserLocalization.string("adblock_enabled"), isOn: $adBlock.isEnabled)
                Text(BrowserLocalization.string("adblock_detail"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if adBlock.hasFailed {
                    Text(BrowserLocalization.string("adblock_failed"))
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section(BrowserLocalization.string("default_browser")) {
                Text(BrowserLocalization.string("default_browser_detail"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if isDefaultBrowser {
                    Label(
                        BrowserLocalization.string("default_browser_current"),
                        systemImage: "checkmark.circle.fill"
                    )
                    .foregroundStyle(.green)
                } else {
                    Button(BrowserLocalization.string("make_default_browser")) {
                        makeDefaultBrowser()
                    }
                    .disabled(isDefaultBrowserUpdateInProgress)
                }

                if isDefaultBrowserUpdateInProgress {
                    ProgressView().controlSize(.small)
                }

                if let defaultBrowserError {
                    Text(defaultBrowserError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section(BrowserLocalization.string("updates")) {
                Text(BrowserLocalization.string("updates_detail"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(BrowserLocalization.string("check_for_updates")) {
                    isCheckingForUpdates = true
                    updateCheckStatus = nil
                    NotificationCenter.default.post(
                        name: BrowserManualUpdate.checkRequested,
                        object: nil
                    )
                }
                .disabled(isCheckingForUpdates)

                if isCheckingForUpdates {
                    HStack(spacing: 8) {
                        ProgressView().controlSize(.small)
                        Text(BrowserLocalization.string("checking_for_updates"))
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else if let updateCheckStatus {
                    Text(updateCheckStatusText(updateCheckStatus))
                        .font(.caption)
                        .foregroundStyle(
                            updateCheckStatus == .unavailable
                                || updateCheckStatus == .configurationMissing
                                ? .red : .secondary
                        )
                }
            }

            Section(BrowserLocalization.string("onboarding_section_title")) {
                Text(BrowserLocalization.string("onboarding_section_detail"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button(BrowserLocalization.string("onboarding_replay")) {
                    BrowserOnboarding.requestReplay()
                    dismiss()
                }
            }
        }
        .settingsFormStyle()
        .onAppear(perform: refreshDefaultBrowserStatus)
        .onReceive(
            NotificationCenter.default.publisher(
                for: NSApplication.didBecomeActiveNotification
            )
        ) { _ in
            refreshDefaultBrowserStatus()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: BrowserManualUpdate.checkFinished
            )
        ) { notification in
            guard let rawValue = notification.userInfo?[
                BrowserManualUpdate.statusUserInfoKey
            ] as? String,
            let status = BrowserManualUpdate.CheckStatus(rawValue: rawValue)
            else { return }
            updateCheckStatus = status
            isCheckingForUpdates = false
        }
    }

    private func refreshDefaultBrowserStatus() {
        isDefaultBrowser = DefaultBrowserService.isDefaultBrowser()
    }

    private func updateCheckStatusText(
        _ status: BrowserManualUpdate.CheckStatus
    ) -> String {
        switch status {
        case .updateAvailable:
            BrowserLocalization.string("update_check_available")
        case .upToDate:
            BrowserLocalization.string("update_check_up_to_date")
        case .checkedRecently:
            BrowserLocalization.string("update_check_recently")
        case .unavailable:
            BrowserLocalization.string("update_check_failed")
        case .configurationMissing:
            BrowserLocalization.string("update_check_not_configured")
        case .checkInProgress:
            BrowserLocalization.string("checking_for_updates")
        }
    }

    private func makeDefaultBrowser() {
        defaultBrowserError = nil
        isDefaultBrowserUpdateInProgress = true
        DefaultBrowserService.makeDefaultBrowser { error in
            isDefaultBrowserUpdateInProgress = false
            isDefaultBrowser = DefaultBrowserService.isDefaultBrowser()
            if let error {
                defaultBrowserError = error.localizedDescription
            } else if !isDefaultBrowser {
                defaultBrowserError = BrowserLocalization.string(
                    "check_default_browser_settings"
                )
            }
        }
    }
}

import BrowserCore
import BrowserEngine
import SwiftUI

/// How much memory the browser may use before it sleeps background tabs.
struct PerformanceSettingsPane: View {
    @AppStorage(BrowserMemoryLimitSettings.defaultsKey)
    private var memoryLimitFraction = BrowserMemoryLimitSettings.defaultFraction

    private let physicalMemoryBytes = ProcessInfo.processInfo.physicalMemory

    var body: some View {
        Form {
            Section(BrowserLocalization.string("memory_management")) {
                LabeledContent(BrowserLocalization.string("memory_limit")) {
                    Text(memoryLimitFraction, format: .percent.precision(.fractionLength(0)))
                        .monospacedDigit()
                }

                Slider(
                    value: $memoryLimitFraction,
                    in: BrowserMemoryLimitSettings.allowedRange,
                    step: 0.05
                ) {
                    Text(BrowserLocalization.string("memory_limit"))
                } minimumValueLabel: {
                    Text("25%").font(.caption)
                } maximumValueLabel: {
                    Text("90%").font(.caption)
                }

                Text(BrowserLocalization.string(
                    "memory_limit_detail",
                    formattedMemoryLimit
                ))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .settingsFormStyle()
        .onChange(of: memoryLimitFraction) { _, newValue in
            let normalized = BrowserMemoryLimitSettings.normalizedFraction(newValue)
            if normalized != newValue {
                memoryLimitFraction = normalized
            }
        }
    }

    private var formattedMemoryLimit: String {
        let bytes = UInt64(Double(physicalMemoryBytes) * memoryLimitFraction)
        return Int64(clamping: bytes).formatted(.byteCount(style: .memory))
    }
}

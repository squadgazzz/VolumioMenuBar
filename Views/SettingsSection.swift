import SwiftUI
import ServiceManagement

struct SettingsSection: View {
    @AppStorage("settingsSectionExpanded") private var isExpanded = false
    @AppStorage("showOnlyActiveDevices") private var showOnlyActive = false
    @AppStorage("showDeviceIP") private var showDeviceIP = false
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("Settings")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                            do {
                                if newValue {
                                    try SMAppService.mainApp.register()
                                } else {
                                    try SMAppService.mainApp.unregister()
                                }
                            } catch {
                                launchAtLogin = !newValue
                            }
                        }

                    Toggle("Hide inactive devices", isOn: $showOnlyActive)

                    Toggle("Show device IP", isOn: $showDeviceIP)
                }
                .toggleStyle(.switch)
                .controlSize(.mini)
                .font(.caption2)
                .padding(.top, 2)
            }
        }
    }
}

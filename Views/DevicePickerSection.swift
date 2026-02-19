import SwiftUI

struct DevicePickerSection: View {
    @Environment(AppState.self) private var appState
    @AppStorage("showOnlyActiveDevices") private var showOnlyActive = false
    @AppStorage("showDeviceIP") private var showDeviceIP = false

    private var visibleDevices: [VolumioDevice] {
        let allDevices = appState.discovery.devices
        guard showOnlyActive else { return allDevices }
        let selectedID = appState.selectedDevice?.id
        return allDevices.filter { $0.isOnline || $0.id == selectedID }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Devices")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            HStack(spacing: 12) {
                Toggle("Active only", isOn: $showOnlyActive)
                Toggle("Show IP", isOn: $showDeviceIP)
            }
            .toggleStyle(.switch)
            .controlSize(.mini)
            .font(.caption2)

            if appState.discovery.devices.isEmpty {
                HStack(spacing: 6) {
                    ProgressView()
                        .controlSize(.small)
                    Text("Scanning for Volumio devices...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } else {
                ForEach(visibleDevices) { device in
                    Button {
                        if device.isOnline {
                            appState.selectDevice(device)
                        }
                    } label: {
                        HStack {
                            Circle()
                                .fill(device.isOnline ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)

                            Text(deviceLabel(device))
                                .lineLimit(1)

                            Spacer()

                            if appState.selectedDevice?.id == device.id {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                    .buttonStyle(HoverButtonStyle())
                    .disabled(!device.isOnline)
                    .opacity(device.isOnline ? 1.0 : 0.5)
                    .padding(.vertical, 2)
                }
            }
        }
        .onChange(of: appState.discovery.devices) { _, _ in
            appState.autoConnectIfNeeded()
        }
    }

    private func deviceLabel(_ device: VolumioDevice) -> String {
        showDeviceIP ? "\(device.name) (\(device.host))" : device.name
    }
}

import SwiftUI

struct DevicePickerSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Devices")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

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
                ForEach(appState.discovery.devices) { device in
                    Button {
                        if device.isOnline {
                            appState.selectDevice(device)
                        }
                    } label: {
                        HStack {
                            Circle()
                                .fill(device.isOnline ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)

                            Text(device.name)
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
}

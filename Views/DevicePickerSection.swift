import AppKit
import SwiftUI

struct DevicePickerSection: View {
    @Environment(AppState.self) private var appState
    @AppStorage("showOnlyActiveDevices") private var showOnlyActive = false
    @AppStorage("showDeviceIP") private var showDeviceIP = false

    private enum ConfirmAction {
        case reboot
        case shutdown
    }

    @State private var confirmingAction: ConfirmAction?

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
                    let isSelected = appState.selectedDevice?.id == device.id
                    if isSelected {
                        selectedDeviceRow(device)
                    } else {
                        unselectedDeviceRow(device)
                    }
                }
            }
        }
        .onChange(of: appState.discovery.devices) { _, _ in
            appState.autoConnectIfNeeded()
        }
        .onChange(of: appState.selectedDevice?.id) { _, _ in
            confirmingAction = nil
        }
    }

    @ViewBuilder
    private func selectedDeviceRow(_ device: VolumioDevice) -> some View {
        if let confirmingAction {
            confirmationRow(action: confirmingAction, device: device)
                .padding(.vertical, 2)
        } else {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)

                MarqueeText(text: deviceLabel(device))
                    .lineLimit(1)

                Spacer(minLength: 4)

                Button {
                    appState.openWebUI()
                } label: {
                    Image(systemName: "globe")
                        .font(.system(size: 11))
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(HoverButtonStyle(padding: EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)))
                .tooltip("Open Web UI")

                Button {
                    confirmingAction = .reboot
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11))
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(HoverButtonStyle(padding: EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)))
                .tooltip("Reboot")

                Button {
                    confirmingAction = .shutdown
                } label: {
                    Image(systemName: "power")
                        .font(.system(size: 11))
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(HoverButtonStyle(padding: EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)))
                .tooltip("Shut Down")
            }
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private func confirmationRow(action: ConfirmAction, device: VolumioDevice) -> some View {
        HStack(spacing: 6) {
            Image(systemName: action == .reboot ? "arrow.clockwise" : "power")
                .font(.system(size: 11))
                .frame(width: 16, alignment: .center)

            Text(action == .reboot ? "Reboot?" : "Shut Down?")
                .foregroundStyle(.secondary)

            Spacer()

            Button("Yes") {
                if action == .reboot {
                    appState.connection?.reboot()
                    appState.disconnectDevice()
                    let deviceToReconnect = device
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak appState] in
                        appState?.selectDevice(deviceToReconnect)
                    }
                } else {
                    appState.connection?.shutdown()
                    appState.disconnectDevice()
                }
                confirmingAction = nil
            }
            .buttonStyle(HoverButtonStyle())

            Button("Cancel") {
                confirmingAction = nil
            }
            .buttonStyle(HoverButtonStyle())
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }

    private func unselectedDeviceRow(_ device: VolumioDevice) -> some View {
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
            }
        }
        .buttonStyle(HoverButtonStyle())
        .disabled(!device.isOnline)
        .opacity(device.isOnline ? 1.0 : 0.5)
        .padding(.vertical, 2)
    }

    private func deviceLabel(_ device: VolumioDevice) -> String {
        showDeviceIP ? "\(device.name) (\(device.host))" : device.name
    }
}

private class PassthroughView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}

private struct TooltipView: NSViewRepresentable {
    let tooltip: String

    func makeNSView(context: Context) -> NSView {
        let view = PassthroughView()
        view.toolTip = tooltip
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        nsView.toolTip = tooltip
    }
}

private extension View {
    func tooltip(_ text: String) -> some View {
        overlay(TooltipView(tooltip: text))
    }
}

private struct MarqueeText: View {
    let text: String

    @State private var isHovered = false
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var offset: CGFloat = 0

    private var isTruncated: Bool { textWidth > containerWidth }
    private var scrollDistance: CGFloat { textWidth - containerWidth + 16 }

    var body: some View {
        GeometryReader { geo in
            Text(text)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .offset(x: offset)
                .onAppear { containerWidth = geo.size.width }
                .onChange(of: geo.size.width) { _, new in containerWidth = new }
                .background(
                    GeometryReader { textGeo in
                        Color.clear.onAppear { textWidth = textGeo.size.width }
                            .onChange(of: text) { _, _ in textWidth = textGeo.size.width }
                    }
                )
        }
        .clipped()
        .frame(height: 16)
        .onHover { hovering in
            isHovered = hovering
            if hovering && isTruncated {
                withAnimation(.linear(duration: Double(scrollDistance) / 30.0).delay(0.3)) {
                    offset = -scrollDistance
                }
            } else {
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = 0
                }
            }
        }
    }
}

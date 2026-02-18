import SwiftUI

struct DeviceActionsSection: View {
    @Environment(AppState.self) private var appState
    @AppStorage("deviceActionsSectionExpanded") private var isExpanded = true

    private enum ConfirmAction {
        case reboot
        case shutdown
    }

    @State private var confirmingAction: ConfirmAction?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("Device")
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
                Button {
                    appState.openWebUI()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                            .frame(width: 16, alignment: .center)
                        Text("Open Web UI")
                    }
                }
                .buttonStyle(HoverButtonStyle())

                if confirmingAction == .reboot {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .frame(width: 16, alignment: .center)
                        Text("Reboot?")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Yes") {
                            if let device = appState.selectedDevice {
                                appState.connection?.reboot()
                                appState.disconnectDevice()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak appState] in
                                    appState?.selectDevice(device)
                                }
                            }
                            confirmingAction = nil
                        }
                        .buttonStyle(HoverButtonStyle())
                        Button("Cancel") {
                            confirmingAction = nil
                        }
                        .buttonStyle(HoverButtonStyle())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                } else {
                    Button {
                        confirmingAction = .reboot
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .frame(width: 16, alignment: .center)
                            Text("Reboot")
                        }
                    }
                    .buttonStyle(HoverButtonStyle())
                }

                if confirmingAction == .shutdown {
                    HStack(spacing: 8) {
                        Image(systemName: "power")
                            .frame(width: 16, alignment: .center)
                        Text("Shut Down?")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button("Yes") {
                            appState.connection?.shutdown()
                            confirmingAction = nil
                            appState.disconnectDevice()
                        }
                        .buttonStyle(HoverButtonStyle())
                        Button("Cancel") {
                            confirmingAction = nil
                        }
                        .buttonStyle(HoverButtonStyle())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                } else {
                    Button {
                        confirmingAction = .shutdown
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "power")
                                .frame(width: 16, alignment: .center)
                            Text("Shutdown")
                        }
                    }
                    .buttonStyle(HoverButtonStyle())
                }
            }
        }
    }
}

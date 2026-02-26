import SwiftUI

struct MenuBarContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DevicePickerSection()
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 4)

            Divider()
                .padding(.vertical, 4)

            if let connection = appState.connection {
                if connection.isConnected {
                    connectedContent
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            ProgressView()
                                .controlSize(.small)
                            Text(connection.statusMessage)
                                .foregroundStyle(.secondary)
                                .font(.caption)
                                .lineLimit(3)
                        }
                        if !connection.connectURL.isEmpty {
                            Text(connection.connectURL)
                                .foregroundStyle(.tertiary)
                                .font(.caption2)
                                .textSelection(.enabled)
                                .lineLimit(2)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
            }

            Divider()
                .padding(.vertical, 4)

            SettingsSection()
                .padding(.horizontal, 12)
                .padding(.vertical, 4)

            HStack {
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .padding(.bottom, 8)
        }
        .onAppear {
            appState.discovery.ensureBrowsing()
        }
    }

    @ViewBuilder
    private var connectedContent: some View {
        NowPlayingSection()
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

        PlaybackControlsSection()
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

        SeekBarSection()
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

        if !appState.queue.isEmpty && appState.playerState?.volatile != true {
            Divider()
                .padding(.vertical, 4)

            QueueSection()
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
        }

        if appState.fusionDSP.isInstalled && appState.fusionDSP.isActive {
            Divider()
                .padding(.vertical, 4)

            EQSection()
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
        }

    }
}

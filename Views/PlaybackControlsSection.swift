import SwiftUI

struct PlaybackControlsSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        HStack(spacing: 16) {
            Spacer()

            Button {
                appState.connection?.previous()
            } label: {
                Image(systemName: "backward.fill")
                    .font(.title3)
            }
            .buttonStyle(HoverButtonStyle())

            Button {
                let state = appState.playerState
                if state?.status == .play {
                    appState.connection?.pause()
                } else if state?.volatile == true, let service = state?.service, !service.isEmpty {
                    appState.connection?.resumeVolatileService(service)
                } else {
                    appState.connection?.play()
                }
            } label: {
                Image(systemName: playPauseIcon)
                    .font(.title2)
            }
            .buttonStyle(HoverButtonStyle())

            Button {
                appState.connection?.next()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title3)
            }
            .buttonStyle(HoverButtonStyle())

            Spacer()
        }
    }

    private var playPauseIcon: String {
        switch appState.playerState?.status {
        case .play:
            return "pause.fill"
        default:
            return "play.fill"
        }
    }
}

import SwiftUI

struct NowPlayingSection: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        if let state = appState.playerState {
            HStack(spacing: 10) {
                albumArtView(state: state)

                VStack(alignment: .leading, spacing: 2) {
                    Text(state.title.isEmpty ? "No Title" : state.title)
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)

                    if !state.artist.isEmpty || !state.album.isEmpty {
                        Text(subtitleText(state: state))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    if !state.trackType.isEmpty {
                        Text(formatText(state: state))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
        }
    }

    @ViewBuilder
    private func albumArtView(state: PlayerState) -> some View {
        let url = albumArtURL(state: state)
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            default:
                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func albumArtURL(state: PlayerState) -> URL? {
        guard !state.albumart.isEmpty else { return nil }
        if state.albumart.hasPrefix("http") {
            return URL(string: state.albumart)
        }
        guard let device = appState.selectedDevice else { return nil }
        return URL(string: "http://\(device.host):\(device.port)\(state.albumart)")
    }

    private func subtitleText(state: PlayerState) -> String {
        [state.artist, state.album]
            .filter { !$0.isEmpty }
            .joined(separator: " - ")
    }

    private func formatText(state: PlayerState) -> String {
        [state.trackType, state.samplerate, state.bitdepth]
            .filter { !$0.isEmpty }
            .joined(separator: " | ")
    }
}

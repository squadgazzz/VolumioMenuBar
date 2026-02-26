import SwiftUI

struct QueueSection: View {
    @Environment(AppState.self) private var appState
    @AppStorage("queueSectionExpanded") private var isExpanded = false

    private var upNext: [(index: Int, item: QueueItem)] {
        guard let position = appState.playerState?.position else { return [] }
        let queue = appState.queue
        let startIndex = position + 1
        guard startIndex < queue.count else { return [] }
        return (startIndex..<queue.count).map { (index: $0, item: queue[$0]) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
            } label: {
                HStack {
                    Text("Up Next")
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
                if upNext.isEmpty {
                    Text("Nothing queued")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.vertical, 2)
                } else {
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(upNext.enumerated()), id: \.offset) { _, entry in
                                Button {
                                    appState.connection?.playIndex(entry.index)
                                } label: {
                                    HStack(spacing: 8) {
                                        Text("\(entry.index - (appState.playerState?.position ?? 0))")
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                            .frame(width: 14, alignment: .trailing)

                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(entry.item.title)
                                                .font(.caption)
                                                .lineLimit(1)
                                            if !entry.item.artist.isEmpty {
                                                Text(entry.item.artist)
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }

                                        Spacer()
                                    }
                                }
                                .buttonStyle(HoverButtonStyle())
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .frame(height: min(CGFloat(upNext.count) * 32, 160))
                }
            }
        }
    }
}

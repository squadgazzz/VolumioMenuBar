import SwiftUI

struct SeekBarSection: View {
    @Environment(AppState.self) private var appState

    @State private var sliderValue: Double = 0
    @State private var isDragging = false
    @State private var timer: Timer?

    private var duration: Int {
        appState.playerState?.duration ?? 0
    }

    private var isDisabled: Bool {
        appState.playerState?.status == .stop || duration == 0 || (appState.playerState?.volatile ?? false)
    }

    private var isPlaying: Bool {
        appState.playerState?.status == .play
    }

    var body: some View {
        VStack(spacing: 4) {
            CustomSeekSlider(
                value: $sliderValue,
                range: 0...max(Double(duration), 1),
                isDragging: $isDragging,
                isDisabled: isDisabled,
                onEnded: {
                    appState.connection?.seek(Int(sliderValue))
                }
            )
            .frame(height: 12)

            HStack {
                Text(formatTime(Int(sliderValue)))
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)

                Spacer()

                Text(formatTime(duration))
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .onAppear {
            syncSlider()
            startTimerIfNeeded()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: appState.playerState?.seek) { _, _ in
            if !isDragging {
                syncSlider()
            }
        }
        .onChange(of: appState.playerState?.duration) { _, _ in
            if !isDragging {
                syncSlider()
                startTimerIfNeeded()
            }
        }
        .onChange(of: isPlaying) { _, _ in
            startTimerIfNeeded()
        }
    }

    private func syncSlider() {
        guard let state = appState.playerState else { return }
        var seekSeconds = Double(state.seek) / 1000.0
        if state.status == .play {
            seekSeconds += Date().timeIntervalSince(state.receivedAt)
        }
        sliderValue = min(seekSeconds, Double(duration))
    }

    private func startTimerIfNeeded() {
        stopTimer()
        guard isPlaying else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard !isDragging, duration > 0 else { return }
            let next = sliderValue + 1
            if next <= Double(duration) {
                sliderValue = next
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct CustomSeekSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    @Binding var isDragging: Bool
    let isDisabled: Bool
    let onEnded: () -> Void

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 12

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let span = range.upperBound - range.lowerBound
            let fraction = span > 0 ? (value - range.lowerBound) / span : 0
            let thumbX = fraction * width

            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(Color.primary.opacity(isDisabled ? 0.05 : 0.12))
                    .frame(height: trackHeight)

                // Filled portion
                Capsule()
                    .fill(isDisabled ? Color.secondary.opacity(0.3) : Color.accentColor)
                    .frame(width: max(0, thumbX), height: trackHeight)

                // Thumb
                Circle()
                    .fill(isDisabled ? Color.secondary.opacity(0.5) : Color.white)
                    .shadow(color: .black.opacity(0.2), radius: 1, y: 0.5)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: thumbX - thumbSize / 2)
            }
            .frame(height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        guard !isDisabled else { return }
                        isDragging = true
                        let fraction = min(max(drag.location.x / width, 0), 1)
                        value = range.lowerBound + fraction * span
                    }
                    .onEnded { _ in
                        guard !isDisabled else { return }
                        isDragging = false
                        onEnded()
                    }
            )
        }
    }
}

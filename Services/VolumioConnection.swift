import Foundation
import SocketIO

@Observable
final class VolumioConnection {
    var isConnected = false
    var isReconnecting = false
    var statusMessage: String = "Connecting..."
    var connectURL: String = ""

    var onPushState: ((PlayerState) -> Void)?
    var onPushInstalledPlugins: (([[String: Any]]) -> Void)?
    var onPushUiConfig: (([String: Any]) -> Void)?

    private let device: VolumioDevice
    private var manager: SocketManager?
    private var socket: SocketIOClient?

    init(device: VolumioDevice) {
        self.device = device
    }

    func connect() {
        disconnect()

        guard let url = device.baseURL else {
            statusMessage = "Invalid URL for \(device.host):\(device.port)"
            return
        }

        connectURL = url.absoluteString
        statusMessage = "Connecting to \(url.absoluteString)..."

        manager = SocketManager(socketURL: url, config: [
            .version(.two),
            .reconnects(true),
            .reconnectWait(3),
            .reconnectWaitMax(30),
            .forceWebsockets(true),
            .log(false)
        ])

        socket = manager?.defaultSocket

        socket?.on(clientEvent: .connect) { [weak self] _, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isConnected = true
                self.isReconnecting = false
                self.statusMessage = "Connected"
            }
            self.socket?.emit("getState")
            self.socket?.emit("getInstalledPlugins")
        }

        socket?.on(clientEvent: .disconnect) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.isConnected = false
                self?.statusMessage = "Disconnected"
            }
        }

        socket?.on(clientEvent: .reconnect) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.isReconnecting = true
                self?.statusMessage = "Reconnecting..."
            }
        }

        socket?.on(clientEvent: .reconnectAttempt) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.isReconnecting = true
                self?.statusMessage = "Reconnecting..."
            }
        }

        socket?.on(clientEvent: .error) { [weak self] data, _ in
            DispatchQueue.main.async {
                let msg = data.first.map { "\($0)" } ?? "Unknown error"
                self?.statusMessage = "Error: \(msg)"
            }
        }

        socket?.on("pushState") { [weak self] data, _ in
            guard let dict = data.first as? [String: Any] else { return }
            let state = PlayerState.from(dict: dict)
            DispatchQueue.main.async {
                self?.onPushState?(state)
            }
        }

        socket?.on("pushInstalledPlugins") { [weak self] data, _ in
            guard let plugins = data.first as? [[String: Any]] else { return }
            DispatchQueue.main.async {
                self?.onPushInstalledPlugins?(plugins)
            }
        }

        socket?.on("pushUiConfig") { [weak self] data, _ in
            guard let config = data.first as? [String: Any] else { return }
            DispatchQueue.main.async {
                self?.onPushUiConfig?(config)
            }
        }

        socket?.connect()
    }

    func disconnect() {
        socket?.removeAllHandlers()
        socket?.disconnect()
        manager?.disconnect()
        manager = nil
        socket = nil
        isConnected = false
        isReconnecting = false
    }

    // MARK: - Playback Commands

    func play() {
        socket?.emit("play")
    }

    func pause() {
        socket?.emit("pause")
    }

    /// Resumes a volatile service (Tidal Connect, Spotify Connect, etc.)
    /// by calling the plugin's `play()` method directly via `callMethod`.
    /// This bypasses the server bug where `volatileService` becomes undefined
    /// after a stop signal, causing `volatilePlay` to silently fail.
    func resumeVolatileService(_ serviceName: String) {
        callMethod(
            endpoint: "music_service/\(serviceName)",
            method: "play",
            data: [:]
        )
    }

    func stop() {
        socket?.emit("stop")
    }

    func next() {
        socket?.emit("next")
    }

    func previous() {
        socket?.emit("prev")
    }

    // MARK: - Volume

    func setVolume(_ value: Int) {
        socket?.emit("volume", value)
    }

    func mute() {
        socket?.emit("mute")
    }

    func unmute() {
        socket?.emit("unmute")
    }

    // MARK: - Seek

    func seek(_ seconds: Int) {
        socket?.emit("seek", seconds)
    }

    // MARK: - System

    func shutdown() {
        socket?.emit("shutdown")
    }

    func reboot() {
        socket?.emit("reboot")
    }

    // MARK: - Plugin UI Config

    func getUiConfig(page: String) {
        socket?.emit("getUiConfig", ["page": page])
    }

    // MARK: - Plugin Call

    func callMethod(endpoint: String, method: String, data: [String: Any]) {
        let payload: [String: Any] = [
            "endpoint": endpoint,
            "method": method,
            "data": data
        ]
        socket?.emit("callMethod", payload)
    }
}

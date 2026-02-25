import Foundation

struct PlayerState {
    var status: PlaybackStatus
    var title: String
    var artist: String
    var album: String
    var albumart: String
    var uri: String
    var position: Int // index in queue
    var seek: Int // milliseconds
    var duration: Int // seconds
    var volume: Int // 0-100
    var mute: Bool
    var service: String
    var volatile: Bool
    var trackType: String
    var samplerate: String
    var bitdepth: String
    var receivedAt: Date

    enum PlaybackStatus: String {
        case play
        case pause
        case stop
        case unknown

        init(from string: String?) {
            switch string?.lowercased() {
            case "play": self = .play
            case "pause": self = .pause
            case "stop": self = .stop
            default: self = .unknown
            }
        }
    }

    static func from(dict: [String: Any]) -> PlayerState {
        PlayerState(
            status: PlaybackStatus(from: dict["status"] as? String),
            title: dict["title"] as? String ?? "",
            artist: dict["artist"] as? String ?? "",
            album: dict["album"] as? String ?? "",
            albumart: dict["albumart"] as? String ?? "",
            uri: dict["uri"] as? String ?? "",
            position: dict["position"] as? Int ?? 0,
            seek: dict["seek"] as? Int ?? 0,
            duration: dict["duration"] as? Int ?? 0,
            volume: dict["volume"] as? Int ?? 0,
            mute: dict["mute"] as? Bool ?? false,
            service: dict["service"] as? String ?? "",
            volatile: (dict["volatile"] as? NSNumber)?.boolValue ?? false,
            trackType: dict["trackType"] as? String ?? "",
            samplerate: dict["samplerate"] as? String ?? "",
            bitdepth: dict["bitdepth"] as? String ?? "",
            receivedAt: Date()
        )
    }
}

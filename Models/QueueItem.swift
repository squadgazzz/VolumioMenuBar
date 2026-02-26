import Foundation

struct QueueItem {
    var title: String
    var artist: String
    var albumart: String
    var uri: String

    static func from(dict: [String: Any]) -> QueueItem {
        QueueItem(
            title: dict["name"] as? String ?? dict["title"] as? String ?? "",
            artist: dict["artist"] as? String ?? "",
            albumart: dict["albumart"] as? String ?? "",
            uri: dict["uri"] as? String ?? ""
        )
    }
}

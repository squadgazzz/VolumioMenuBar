import Foundation

struct VolumioDevice: Identifiable, Hashable {
    let id: String // UUID from TXT record or synthesized
    var name: String
    var host: String
    var port: Int
    var isOnline: Bool

    var baseURL: URL? {
        URL(string: "http://\(host):\(port)")
    }

    var webUIURL: URL? {
        baseURL
    }

    var fusionDSPURL: URL? {
        baseURL?.appendingPathComponent("plugin/audio_interface-fusiondsp")
    }
}

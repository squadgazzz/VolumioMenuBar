import Foundation

struct DSPPreset: Identifiable, Hashable {
    var id: String { value }
    let value: String
    let label: String
}

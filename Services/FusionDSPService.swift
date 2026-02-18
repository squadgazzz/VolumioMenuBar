import Foundation
import AppKit

@Observable
final class FusionDSPService {
    var isInstalled = false
    var isActive = false
    var dspType: String = ""
    var presets: [DSPPreset] = []
    var currentPreset: DSPPreset?
    var isLoading = false

    /// DSP types that don't support presets
    private let noPresetTypes: Set<String> = ["EQ3", "purecgui"]

    var supportsPresets: Bool {
        !noPresetTypes.contains(dspType)
    }

    private weak var connection: VolumioConnection?
    private var device: VolumioDevice?

    func configure(with connection: VolumioConnection, device: VolumioDevice) {
        self.connection = connection
        self.device = device
        reset()
    }

    func reset() {
        isInstalled = false
        isActive = false
        dspType = ""
        presets = []
        currentPreset = nil
    }

    func handleInstalledPlugins(_ plugins: [[String: Any]]) {
        let fusionPlugin = plugins.first { plugin in
            plugin["name"] as? String == "fusiondsp" &&
            plugin["category"] as? String == "audio_interface"
        }

        if let plugin = fusionPlugin {
            isInstalled = true
            isActive = plugin["active"] as? Bool ?? false
            if isActive {
                fetchPresets()
            }
        } else {
            isInstalled = false
            isActive = false
        }
    }

    func fetchPresets() {
        isLoading = true
        connection?.getUiConfig(page: "audio_interface/fusiondsp")
    }

    func handleUiConfig(_ config: [String: Any]) {
        isLoading = false

        guard let sections = config["sections"] as? [[String: Any]] else {
            return
        }

        // Section 0: DSP type (field id: "selectedsp")
        if let section = sections.first(where: { sectionContainsField($0, id: "selectedsp") }),
           let content = section["content"] as? [[String: Any]],
           let field = content.first(where: { $0["id"] as? String == "selectedsp" }),
           let valueObj = field["value"] as? [String: Any],
           let dspTypeValue = valueObj["value"] as? String {
            self.dspType = dspTypeValue
        }

        guard supportsPresets else { return }

        // Preset section (field id: "usethispreset")
        if let section = sections.first(where: { sectionContainsField($0, id: "usethispreset") }),
           let content = section["content"] as? [[String: Any]],
           let field = content.first(where: { $0["id"] as? String == "usethispreset" }) {

            // Parse preset options
            if let options = field["options"] as? [[String: Any]] {
                self.presets = options.compactMap { opt in
                    guard let value = opt["value"] as? String,
                          let label = opt["label"] as? String else { return nil }
                    return DSPPreset(value: value, label: label)
                }
            }

            // Parse current preset — match by label because the plugin's
            // value.value is often "no preset used" even when a preset is active.
            // The value.label holds the actual preset name.
            if let currentValue = field["value"] as? [String: Any],
               let label = currentValue["label"] as? String,
               let match = self.presets.first(where: { $0.label == label }) {
                self.currentPreset = match
            } else {
                self.currentPreset = nil
            }
        }
    }

    private func sectionContainsField(_ section: [String: Any], id: String) -> Bool {
        guard let content = section["content"] as? [[String: Any]] else { return false }
        return content.contains { $0["id"] as? String == id }
    }

    func switchPreset(_ preset: DSPPreset) {
        currentPreset = preset
        connection?.callMethod(
            endpoint: "audio_interface/fusiondsp",
            method: "usethispreset",
            data: [
                "usethispreset": [
                    "value": preset.value,
                    "label": preset.label
                ]
            ]
        )
    }

    func openFusionDSPSettings() {
        guard let device, let url = device.fusionDSPURL else { return }
        NSWorkspace.shared.open(url)
    }
}

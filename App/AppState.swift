import Foundation
import AppKit

@Observable
final class AppState {
    let discovery = DeviceDiscoveryService()
    var selectedDevice: VolumioDevice?
    var connection: VolumioConnection?
    var playerState: PlayerState?
    var fusionDSP = FusionDSPService()

    private static let lastDeviceUUIDKey = "lastConnectedDeviceUUID"

    var lastConnectedDeviceUUID: String? {
        get { UserDefaults.standard.string(forKey: Self.lastDeviceUUIDKey) }
        set { UserDefaults.standard.set(newValue, forKey: Self.lastDeviceUUIDKey) }
    }

    init() {
        discovery.startBrowsing()
    }

    func selectDevice(_ device: VolumioDevice) {
        connection?.disconnect()
        playerState = nil
        selectedDevice = device
        lastConnectedDeviceUUID = device.id

        let conn = VolumioConnection(device: device)
        connection = conn
        fusionDSP.configure(with: conn, device: device)

        conn.onPushState = { [weak self] state in
            self?.playerState = state
        }
        conn.onPushInstalledPlugins = { [weak self] plugins in
            self?.fusionDSP.handleInstalledPlugins(plugins)
        }
        conn.onPushUiConfig = { [weak self] config in
            self?.fusionDSP.handleUiConfig(config)
        }
        conn.connect()
    }

    func autoConnectIfNeeded() {
        guard selectedDevice == nil,
              let lastUUID = lastConnectedDeviceUUID,
              let device = discovery.devices.first(where: { $0.id == lastUUID && $0.isOnline }) else {
            return
        }
        selectDevice(device)
    }

    func disconnectDevice() {
        connection?.disconnect()
        connection = nil
        playerState = nil
        selectedDevice = nil
    }

    func openWebUI() {
        guard let device = selectedDevice, let url = device.webUIURL else { return }
        NSWorkspace.shared.open(url)
    }
}

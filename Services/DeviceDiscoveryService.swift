import Foundation
import Network

@Observable
final class DeviceDiscoveryService {
    var devices: [VolumioDevice] = []

    private var browser: NWBrowser?
    private var resolveConnections: [String: NWConnection] = [:]

    func startBrowsing() {
        guard browser == nil else { return }

        let params = NWParameters()
        params.includePeerToPeer = true
        let descriptor = NWBrowser.Descriptor.bonjour(type: "_Volumio._tcp", domain: "local.")
        let newBrowser = NWBrowser(for: descriptor, using: params)
        browser = newBrowser

        newBrowser.browseResultsChangedHandler = { [weak self] results, changes in
            guard let self else { return }
            for change in changes {
                switch change {
                case .added(let result):
                    self.resolveAndAdd(result: result)
                case .removed(let result):
                    self.markOffline(result: result)
                default:
                    break
                }
            }
        }

        newBrowser.stateUpdateHandler = { [weak self] state in
            switch state {
            case .failed:
                // Clean up so startBrowsing() can retry
                newBrowser.cancel()
                self?.browser = nil
            default:
                break
            }
        }

        newBrowser.start(queue: .main)
    }

    func ensureBrowsing() {
        if browser == nil || devices.isEmpty {
            stopBrowsing()
            startBrowsing()
        }
    }

    func stopBrowsing() {
        browser?.cancel()
        browser = nil
        for (_, conn) in resolveConnections {
            conn.cancel()
        }
        resolveConnections.removeAll()
    }

    private func resolveAndAdd(result: NWBrowser.Result) {
        let deviceID = endpointID(result.endpoint)

        // Extract metadata from TXT record
        var deviceName = deviceID
        var deviceUUID = deviceID
        if case let .service(name, _, _, _) = result.endpoint {
            deviceName = name
        }
        if case let .bonjour(txtRecord) = result.metadata {
            if let uuidEntry = txtRecord["UUID"] {
                deviceUUID = uuidEntry
            }
            if let nameEntry = txtRecord["volumioName"] {
                deviceName = nameEntry
            }
        }

        // Resolve the endpoint to get IP + port, preferring IPv4
        let tcpParams = NWParameters.tcp
        if let ipOptions = tcpParams.defaultProtocolStack.internetProtocol as? NWProtocolIP.Options {
            ipOptions.version = .v4
        }
        let conn = NWConnection(to: result.endpoint, using: tcpParams)
        resolveConnections[deviceID] = conn

        conn.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                if let endpoint = conn.currentPath?.remoteEndpoint,
                   case let .hostPort(host, port) = endpoint {
                    let hostStr = self.hostString(from: host)
                    let portInt = Int(port.rawValue)
                    DispatchQueue.main.async {
                        let device = VolumioDevice(
                            id: deviceUUID,
                            name: deviceName,
                            host: hostStr,
                            port: portInt,
                            isOnline: true
                        )
                        if let idx = self.devices.firstIndex(where: { $0.id == deviceUUID }) {
                            self.devices[idx] = device
                        } else {
                            self.devices.append(device)
                        }
                    }
                }
                conn.cancel()
                self.resolveConnections.removeValue(forKey: deviceID)
            case .failed:
                conn.cancel()
                self.resolveConnections.removeValue(forKey: deviceID)
            default:
                break
            }
        }

        conn.start(queue: .main)
    }

    private func markOffline(result: NWBrowser.Result) {
        let deviceID = endpointID(result.endpoint)

        // Try to find by UUID from TXT record
        var deviceUUID = deviceID
        if case let .bonjour(txtRecord) = result.metadata,
           let uuidEntry = txtRecord["UUID"] {
            deviceUUID = uuidEntry
        }

        DispatchQueue.main.async {
            if let idx = self.devices.firstIndex(where: { $0.id == deviceUUID }) {
                self.devices[idx].isOnline = false
            }
        }
    }

    private func endpointID(_ endpoint: NWEndpoint) -> String {
        switch endpoint {
        case .service(let name, _, _, _):
            return name
        default:
            return endpoint.debugDescription
        }
    }

    private func hostString(from host: NWEndpoint.Host) -> String {
        switch host {
        case .ipv4(let addr):
            // Strip interface suffix (e.g. "192.168.1.1%en0" → "192.168.1.1")
            let raw = "\(addr)"
            if let pctIdx = raw.firstIndex(of: "%") {
                return String(raw[raw.startIndex..<pctIdx])
            }
            return raw
        case .ipv6(let addr):
            // IPv6 addresses must be wrapped in brackets for URLs.
            // Strip zone IDs for simplicity since they cause URL encoding issues.
            let raw = "\(addr)"
            if let pctIdx = raw.firstIndex(of: "%") {
                return "[\(raw[raw.startIndex..<pctIdx])]"
            }
            return "[\(raw)]"
        case .name(let name, _):
            return name
        @unknown default:
            return "\(host)"
        }
    }
}

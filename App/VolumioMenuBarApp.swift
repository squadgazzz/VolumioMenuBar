import SwiftUI
import ServiceManagement

@main
struct VolumioMenuBarApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView()
                .environment(appState)
                .frame(width: 320)
        } label: {
            Image(nsImage: MenuBarIcon.create())
        }
        .menuBarExtraStyle(.window)
    }
}

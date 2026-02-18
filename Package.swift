// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VolumioMenuBar",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/socketio/socket.io-client-swift", from: "16.1.1")
    ],
    targets: [
        .executableTarget(
            name: "VolumioMenuBar",
            dependencies: [
                .product(name: "SocketIO", package: "socket.io-client-swift")
            ],
            path: ".",
            exclude: [
                "project.yml",
                "Info.plist",
                "VolumioMenuBar.entitlements",
                "VolumioMenuBar.xcodeproj",
                "VolumioMenuBar.app",
                "AppIcon.icns",
                "Resources",
                "build.sh"
            ],
            sources: [
                "App",
                "Models",
                "Services",
                "Views"
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        )
    ]
)

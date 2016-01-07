import PackageDescription

let package = Package(
    name: "SwiftAPI",
    dependencies: [
        .Package(url: "https://github.com/Zewo/WebSocket.git", majorVersion: 0, minor: 1)
    ],
    targets: [
        Target(
            name: "Example",
            dependencies: [.Target(name: "Library")]),
        Target(name: "Library")
    ]
)

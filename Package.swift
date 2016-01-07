import PackageDescription

let package = Package(
    name: "SwiftAPI",
    dependencies: [
        .Package(url: "https://github.com/Zewo/WebSocket.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/HTTPParser.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/HTTP.git", Version(0,1,2)),
        .Package(url: "https://github.com/Zewo/OpenSSL.git", Version(0,1,4))
    ],
    targets: [
        Target(
            name: "Example",
            dependencies: [.Target(name: "Library")]),
        Target(
            name: "Library",
            dependencies: [.Target(name: "Zeal")]),
        Target(name: "Zeal"),
        Target(
            name: "ZealExample",
            dependencies: [.Target(name: "Zeal")])
    ]
)

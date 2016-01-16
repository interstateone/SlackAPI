import PackageDescription

let package = Package(
    name: "SwiftAPI",
    dependencies: [
        .Package(url: "https://github.com/interstateone/WebSocket.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/interstateone/OpenSSL.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/HTTPParser.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/tyrone-sudeium/JSONCore.git", majorVersion: 1, minor: 0)
    ],
    targets: [
        Target(
            name: "Example",
            dependencies: [.Target(name: "SlackAPI")]),
        Target(
            name: "SlackAPI",
            dependencies: [.Target(name: "Zeal")]),
        Target(name: "Zeal"),
        Target(
            name: "ZealExample",
            dependencies: [.Target(name: "Zeal")]),
        Target(
            name: "WebSocketExample",
            dependencies: [.Target(name: "Zeal")])
    ]
)

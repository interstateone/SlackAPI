import PackageDescription

#if os(OSX)
    let openSSLURL = "https://github.com/Zewo/COpenSSL-OSX.git"
#else
    let openSSLURL = "https://github.com/Zewo/COpenSSL.git"
#endif

let package = Package(
    name: "SwiftAPI",
    dependencies: [
        .Package(url: "https://github.com/interstateone/WebSocket.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/interstateone/OpenSSL.git", majorVersion: 0, minor: 1),
        .Package(url: openSSLURL, majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/CURIParser.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/CLibvenice.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/Venice.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/CHTTPParser.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/HTTPParser.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/Zewo/HTTP.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/tyrone-sudeium/JSONCore.git", majorVersion: 1, minor: 0)
    ],
    targets: [
        Target(name: "SlackAPI", dependencies: [.Target(name: "Zeal")]),
        Target(name: "Zeal")
    ]
)

# SlackAPI

[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org)
[![Platforms Mac | Linux](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux-lightgray.svg?style=flat)](https://swift.org)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)

A Swift library for interacting with the Slack API, including Real Time Messaging (RTM)

You can see an example use of this library in [starter-swift-bot](https://github.com/interstateone/starter-swift-bot), a Slack bot written in Swift that is hosted on [Beep Boop](https://beepboophq.com) (which runs your bots in Docker containers).

## Installation

There are some C library dependencies that are required for SlackAPI. You can install them on supported operating systems like so:

### Ubuntu

```bash
echo "deb [trusted=yes] http://apt.zewo.io/ deb ./" | sudo tee --append /etc/apt/sources.list
sudo apt-get update
sudo apt-get install libvenice
sudo apt-get install uri-parser
sudo apt-get install http-parser
sudo apt-get install libssl-dev
```

### OS X

```bash
brew tap zewo/tap
brew update
brew install libvenice
brew install uri_parser
brew install http_parser
brew install openssl
brew link --force openssl
```

Then add SlackAPI to your package's `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/interstateone/SlackAPI.git", majorVersion: 1, minor: 0)
    ]
)
```

## License

SlackAPI is available under the [MIT License](https://tldrlegal.com/license/mit-license), see the [LICENSE](https://github.com/interstateone/SlackAPI/blob/master/LICENSE) file for details.

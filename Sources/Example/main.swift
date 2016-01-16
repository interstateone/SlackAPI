#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

import SlackAPI

guard let token = String.fromCString(getenv("SLACK_TOKEN")) where !token.isEmpty else {
    print("A non-empty variable named SLACK_TOKEN must be available in the environment.")
    exit(1)
}

do {
    let RTM = try Slack(token: token).startRTM()

    guard let botUser = RTM.user else { exit(1) }

    RTM.listen { event in
        switch event {
        // Be friendly!
        case let message as Message where message.subType == .ChannelJoin:
            print("\(message.user) joined \(message.channel)")
            RTM.send(botUser.say("Hey \(message.user?.name ?? "kiddo"), welcome!", in: message.channel))
        // Be annoying.
        case let message as Message:
            print("Message received from \(message.user?.ID): \(message.text)")
            RTM.send(Message(user: botUser, channel: message.channel, text: "Right back at ya, kid."))
        default:
            break
        }
    }

    RTM.waitUntilClosed()
}
catch {
    print(error)
}


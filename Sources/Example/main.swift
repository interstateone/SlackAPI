#if os(Linux)
import Glibc
#else
import Darwin.C
#endif

import SlackAPI

do {
    let RTM = try Slack(token: "***REMOVED***").startRTM()

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


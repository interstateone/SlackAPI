public final class Slack {
    let http = PlaceholderHTTP()
    let token: String
    var user: User?

    public init(token: String) {
        self.token = token
        // TODO: Setup HTTP client
    }

    public func startRTM() -> SlackRTM {
        // post to rtm.start
        http.post()

        // create user from self info
        user = User(ID: "", name: "")

        // get WS URL from response
        let URL = ""

        // create RTM with URL
        let RTM = SlackRTM(slack: self, URL: URL)
        RTM.connect()

        return RTM
    }
}

public final class SlackRTM {
    private let socket: WebSocketClient
    private let slack: Slack
    private var listeners = [Listener]()
    let URL: String

    public var user: User? {
        return slack.user
    }

    init(slack: Slack, URL: String) {
        self.slack = slack
        self.URL = URL
        self.socket = PlaceholderSocket(url: URL)
    }

    func connect() {
        socket.connect()
        socket.onString { string in
            do {
                let event = try self.createEvent(string)
                self.listeners.forEach { listener in
                    listener(event)
                }
            }
            catch {
            }
        }
    }

    private func createEvent(JSONString: String) throws -> Event {
        // TODO: Turn string into JSON
        let JSON: [String: AnyObject] = [:]
        guard let eventTypeString = JSON["type"] as? String, eventType = EventType(rawValue: eventTypeString) else {
            throw Errors.InvalidJSON
        }

        switch eventType {
        case .Message:
            return Message(JSON: JSON)
        default: throw Errors.InvalidJSON
        }
    }

    public typealias Listener = (Event) -> Void
    public func listen(listener: Listener) {
        listeners.append(listener)
    }

    private var lastMessageID = 0
    public func send(message: Message) {
        // This isn't thread-safe
        lastMessageID += 1
        socket.writeString("") // TODO: write the JSON string representation
    }
}

protocol HTTPClient {
    init()
    func post()
}
protocol WebSocketClient {
    init(url: String)
    func connect()
    func onString(handler: (String) -> Void)
    func writeString(string: String)
}
final class PlaceholderHTTP: HTTPClient {
    init() {}
    func post() {}
}
final class PlaceholderSocket: WebSocketClient {
    init(url: String) {}
    func connect() {}
    func onString(handler: (String) -> Void) {}
    func writeString(string: String) {}
}

enum Errors: ErrorType {
    case InvalidJSON
}

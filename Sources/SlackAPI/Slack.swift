import Core
import Zeal
import OpenSSL
import WebSocket
import Venice
import HTTP
import JSONCore

public final class Slack {
    let http = HTTPClient(host: "slack.com", port: 443, SSL: SSLClientContext())
    let token: String
    var user: User?

    public init(token: String) {
        self.token = token
    }

    public func startRTM() throws -> SlackRTM {
        // post to rtm.start
        let formEncodedBody = "token=\(token)"
        let contentLength: Int = formEncodedBody.data.count
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded",
            "Content-Length": String(contentLength)
        ]
        let startChannel = Channel<(Response, StreamType)>()
        print("posting to rtm.start")
        co {
            self.http.post("/api/rtm.start", headers: headers, body: formEncodedBody) { result in
                do {
                    let (response, stream) = try result()
                    startChannel.send(response, stream)
                }
                catch {
                    print(error)
                }
            }
        }
        let (response, stream) = startChannel.receive()!
        let resultJSON = try JSONParser.parseString(response.bodyString!)

        // create user from self info
        user = User(ID: resultJSON["self"]!["id"]!.string!, name: resultJSON["self"]!["name"]!.string!)

        // get WS URL from response
        let URL = resultJSON["url"]!.string!

        // create RTM with URL
        let RTM = SlackRTM(slack: self, URL: URL, response: response, stream: stream)

        return RTM
    }
}

public final class SlackRTM {
    private let http: HTTPClient
    private let webSocketClient: WebSocketClient
    private let webSocket: WebSocket
    private let slack: Slack
    public typealias Listener = (Event) -> Void
    private var listeners = [Listener]()
    let URL: String
    public let done = Channel<Void>()

    public var user: User? {
        return slack.user
    }

    init(slack: Slack, URL: String, response: Response, stream: StreamType) {
        self.slack = slack
        self.URL = URL
        let webSocketChannel = Channel<WebSocket>()

        let headers: [String: String] = [
            "Upgrade": "websocket",
            "Connection": "Upgrade",
            // TODO: Generate a random nonce
            "Sec-WebSocket-Key": Base64.encode(Data(bytes: [0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5])).string!,
            "Sec-WebSocket-Version": "13"
        ]

        let webSocketClient = WebSocketClient { webSocket in 
            webSocketChannel.send(webSocket)
        }

        let uri = URI(string: URL)
        let http = HTTPClient(host: uri.host!, port: 443, SSL: SSLClientContext())

        co {
            http.get(uri.path!, headers: headers) { result in
                do {
                    let (response, stream) = try result()
                    print("response: \(response)")

                    webSocketClient.handleResponse(response, stream)
                } catch {
                    print("error: \(error)")
                }
            }
        }

        self.http = http
        self.webSocketClient = webSocketClient
        webSocket = webSocketChannel.receive()! 

        webSocket.listen { webSocketEvent in
            switch webSocketEvent {
            case .Text(let text):
                do {
                    let event = try self.createEvent(text)
                    self.dispatchEvent(event)
                }
                catch {
                    print("Unable to create event for JSON: \(text)")
                }
            case .Ping(let buffer):
                self.webSocket.pong(buffer)
            case .Close(let code, let reason):
                print("Received close event with code: \(code), reason: \(reason)")
                self.done.receive()
            default:
                print("Received unhandled event: \(webSocketEvent)")
            }
        }

        let ticker = Ticker(period: 2 * second)
        co {
            for _ in ticker.channel {
                // self.send(Ping())
            }
        } 
    }

    private func createEvent(JSONString: String) throws -> Event {
        let json = try JSONParser.parseString(JSONString)
        guard let eventTypeString = json["type"]?.string, eventType = EventType(rawValue: eventTypeString) else {
            throw Errors.InvalidJSON
        }

        switch eventType {
        case .Message: return Message(json: json)
        case .Ping: return Ping(json: json)
        case .PresenceChange: return PresenceChange(json: json)
        case .ChannelJoined: return ChannelJoined(json: json)
        default: throw Errors.InvalidJSON
        }
    }

    func dispatchEvent(event: Event) {
        print("Dispatching event \(event)")
        for listener in listeners {
            listener(event)
        }
    }

    public func listen(listener: Listener) {
        listeners.append(listener)
    }

    public func waitUntilClosed() {
        done.send()
    }
    
    private var lastEventID: Int64 = 0
    public func send(event: Event) {
        lastEventID += 1

        var json = event.JSON
        json["id"] = JSONValue.JSONNumber(.JSONIntegral(lastEventID))

        do {
            let jsonString = try JSONSerializer.serializeValue(json)
            print("Sending \(jsonString)")
            webSocket.send(jsonString)
        }
        catch {
            print("Error serializing JSON for event: \(error)")
        }
    }
}

enum Errors: ErrorType {
    case InvalidJSON
}

import Core
import HTTP
import WebSocket
import Zeal
import OpenSSL

let webSocketClient = WebSocketClient { webSocket in
    print("WebSocket connected")
    webSocket.send("Hello!")
    webSocket.listen { event in
        switch event {
        case .Binary(let data):
            webSocket.send(data)
        case .Text(let text):
            print("received: \(text)")
        case .Ping(let data):
            webSocket.pong(data)
        case .Pong(let data):
            print("pong")
            break
        case .Close(let code, let reason):
            print("WebSocket closed")
        }
    }
}

let client = HTTPClient(host: "echo.websocket.org", port: 443, SSL: SSLClientContext())
let headers: [String: String] = [
    "Upgrade": "websocket",
    "Connection": "Upgrade",
    // TODO: Generate a random nonce
    "Sec-WebSocket-Key": Base64.encode(Data(bytes: [0,1,2,3,4,5,6,7,8,9,0,1,2,3,4,5])).string!,
    "Sec-WebSocket-Version": "13"
]
client.get("/", headers: headers) { result in
    do {
        let (response, stream) = try result()
        print("response: \(response)")

        webSocketClient.handleResponse(response, stream)
    } catch {
        print("error: \(error)")
    }
}

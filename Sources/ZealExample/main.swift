import Core
import HTTP
import Zeal
import OpenSSL

let client = HTTPClient(host: "www.apple.com", port: 443, SSL: SSLClientContext())

client.get("/") { result in
    do {
        let response = try result()
        print("response: \(response)")
    } catch {
        print("error: \(error)")
    }
}

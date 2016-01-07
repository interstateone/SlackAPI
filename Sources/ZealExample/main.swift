import Core
import HTTP
import Zeal

let client = HTTPClient(host: "www.apple.com", port: 80)
print(client)

client.get("/") { result in
    do {
        let response = try result()
        print("response: \(response)")
    } catch {
        print("error: \(error)")
    }
}

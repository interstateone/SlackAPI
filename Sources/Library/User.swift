public final class User: CustomStringConvertible {
    public let ID: String
    public let name: String

    public init(ID: String, name: String) {
        self.ID = ID
        self.name = name
    }

    public func say(text: String, in channel: String) -> Message {
        return Message(user: self, channel: channel, text: text)
    }

    // MARK: CustomStringConvertible

    public var description: String {
        return "\(ID): \(name)"
    }
}

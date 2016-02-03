import JSONCore

public final class Message: Event {
    public let type = EventType.Message

    public var timestamp = Timestamp.Pending
    public let channel: String
    public var user: User? = nil
    public let text: String
    public let subType: MessageType?

    // TODO: Add init for received messages with appropriate timestamp

    public init(user: User, channel: String, text: String) {
        self.user = user
        self.channel = channel
        self.text = text
        self.subType = nil
    }

    // MARK: JSONRepresentable

    public var JSON: JSONValue {
        let jsonValue: JSONValue = [
            "type": JSONValue.JSONString(type.rawValue),
            "channel": JSONValue.JSONString(channel),
            "text": JSONValue.JSONString(text)
        ]
        return jsonValue
    }

    public init(json: JSONValue) {
        self.channel = json["channel"]!.string!
        self.user = User(ID: json["user"]!.string!, name: "")
        self.text = json["text"]!.string!
        self.subType = nil
    }
}

public enum Timestamp {
    case Pending
    case Received(String)
}

/// https://api.slack.com/events/message#message_subtypes
public enum MessageType: String {
    /// A message was posted by an integration
    case bot_message = "bot_message"
    /// A /me message was sent
    case me_message = "me_message"
    /// A message was changed
    case message_changed = "message_changed"
    /// A message was deleted
    case message_deleted = "message_deleted"
    /// A team member joined a channel
    case ChannelJoin = "channel_join"
    /// A team member left a channel
    case channel_leave = "channel_leave"
    /// A channel topic was updated
    case channel_topic = "channel_topic"
    /// A channel purpose was updated
    case channel_purpose = "channel_purpose"
    /// A channel was renamed
    case channel_name = "channel_name"
    /// A channel was archived
    case channel_archive = "channel_archive"
    /// A channel was unarchived
    case channel_unarchive = "channel_unarchive"
    /// A team member joined a group
    case group_join = "group_join"
    /// A team member left a group
    case group_leave = "group_leave"
    /// A group topic was updated
    case group_topic = "group_topic"
    /// A group purpose was updated
    case group_purpose = "group_purpose"
    /// A group was renamed
    case group_name = "group_name"
    /// A group was archived
    case group_archive = "group_archive"
    /// A group was unarchived
    case group_unarchive = "group_unarchive"
    /// A file was shared into a channel
    case file_share = "file_share"
    /// A comment was added to a file
    case file_comment = "file_comment"
    /// A file was mentioned in a channel
    case file_mention = "file_mention"
    /// An item was pinned in a channel
    case pinned_item = "pinned_item"
    /// An item was unpinned from a channel
    case unpinned_item = "unpinned_item"
}

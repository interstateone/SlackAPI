import JSONCore

public protocol JSONRepresentable {
    var JSON: JSONValue { get }
    init(json: JSONValue)
}

public protocol Event: JSONRepresentable {
    var type: EventType { get }
}

extension Event {
    public var JSON: JSONValue {
        let json: JSONValue = [
            "type": JSONValue.JSONString(type.rawValue)
        ]
        return json
    }
}

public final class Ping: Event {
    public let type = EventType.Ping
    init() {}
    public init(json: JSONValue) {}
}

public final class PresenceChange: Event {
    public let type = EventType.PresenceChange
    init() {}
    public init(json: JSONValue) {}
}

public final class ChannelJoined: Event {
    public let type = EventType.ChannelJoined
    init() {}
    public init(json: JSONValue) {}
}

// https://api.slack.com/rtm#events
public enum EventType: String {
    case Hello = "hello"
    case Message = "message"
    case UserTyping = "user_typing"
    case ChannelMarked = "channel_marked"
    case ChannelCreated = "channel_created"
    case ChannelJoined = "channel_joined"
    case ChannelLeft = "channel_left"
    case ChannelDeleted = "channel_deleted"
    case ChannelRename = "channel_rename"
    case ChannelArchive = "channel_archive"
    case ChannelUnarchive = "channel_unarchive"
    case ChannelHistoryChanged = "channel_history_changed"
    case DndUpdated = "dnd_updated"
    case DndUpdatedUser = "dnd_updated_user"
    case ImCreated = "im_created"
    case ImOpen = "im_open"
    case ImClose = "im_close"
    case ImMarked = "im_marked"
    case ImHistoryChanged = "im_history_changed"
    case GroupJoined = "group_joined"
    case GroupLeft = "group_left"
    case GroupOpen = "group_open"
    case GroupClose = "group_close"
    case GroupArchive = "group_archive"
    case GroupUnarchive = "group_unarchive"
    case GroupRename = "group_rename"
    case GroupMarked = "group_marked"
    case GroupHistoryChanged = "group_history_changed"
    case FileCreated = "file_created"
    case FileShared = "file_shared"
    case FileUnshared = "file_unshared"
    case FilePublic = "file_public"
    case FilePrivate = "file_private"
    case FileChange = "file_change"
    case FileDeleted = "file_deleted"
    case FileCommentAdded = "file_comment_added"
    case FileCommentEdited = "file_comment_edited"
    case FileCommentDeleted = "file_comment_deleted"
    case PinAdded = "pin_added"
    case PinRemoved = "pin_removed"
    case PresenceChange = "presence_change"
    case ManualPresenceChange = "manual_presence_change"
    case Ping = "ping"
    case PrefChange = "pref_change"
    case UserChange = "user_change"
    case TeamJoin = "team_join"
    case StarAdded = "star_added"
    case StarRemoved = "star_removed"
    case ReactionAdded = "reaction_added"
    case ReactionRemoved = "reaction_removed"
    case EmojiChanged = "emoji_changed"
    case CommandsChanged = "commands_changed"
    case TeamPlanChange = "team_plan_change"
    case TeamPrefChange = "team_pref_change"
    case TeamRename = "team_rename"
    case TeamDomainChange = "team_domain_change"
    case EmailDomainChanged = "email_domain_changed"
    case TeamProfileChange = "team_profile_change"
    case TeamProfileDelete = "team_profile_delete"
    case TeamProfileReorder = "team_profile_reorder"
    case BotAdded = "bot_added"
    case BotChanged = "bot_changed"
    case AccountsChanged = "accounts_changed"
    case TeamMigrationStarted = "team_migration_started"
    case SubteamCreated = "subteam_created"
    case SubteamUpdated = "subteam_updated"
    case SubteamSelfAdded = "subteam_self_added"
    case SubteamSelfRemoved = "subteam_self_removed"
    case Unsupported = ""
}

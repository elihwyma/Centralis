//
//  Edulink_Message.swift
//  Centralis
//
//  Created by Amy While on 10/01/2022.
//

import Foundation
import Evander
import SerializedSwift

public final class Message: EdulinkBase {
    
    @SerializedTransformable<DateConverter> var date: Date?
    @SerializedTransformable<DateConverter> var read: Date?
    @Serialized(default: "email") var type: String
    @Serialized var subject: String?
    @Serialized var body: String?
    
    @Serialized(default: [Attachment]()) var attachments: [Attachment]
    @Serialized var sender: Sender
    
    public static let attachmentFolder = EvanderNetworking._cacheDirectory.appendingPathComponent("Attachments")
    
    public static func ==(lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id && rhs.read == lhs.read
    }
    
    init(id: String, date: Date?, read: Date?, type: String, subject: String?, body: String?, attachments: [Attachment], sender: Sender) {
        super.init()
        self.id = id
        self.date = date
        self.read = read
        self.type = type
        self.subject = subject
        self.body = body
        self.attachments = attachments
        self.sender = sender
    }
    
    required public init() {}
    
    public class func updateMessages(totalPages: Int? = nil, currentPage: Int? = nil, messages: [String: Message] = PersistenceDatabase.shared.messages, indexing: Bool = false, _ completion: @escaping (String?, [String: Message]?) -> Void) {
        var totalPages = totalPages
        var messages = messages
        EvanderNetworking.edulinkDict(method: "Communicator.Inbox", params: [.custom(key: "page", value: currentPage ?? 1),
                                                                             .custom(key: "per_page", value: 50)]) { _, _, error, result in
            guard let result = result else {
                return completion(error ?? "Unknown Error", nil)
            }
            if totalPages == nil {
                guard let pagination = result["pagination"] as? [String: Any],
                      let _totalPages = pagination["total_pages"] as? Int else { return completion(error ?? "Unknown Error", nil) }
                totalPages = _totalPages
            }
            guard let messageArray = result["messages"] as? [[String: Any]] else { return completion("Unknown Error", nil) }
            do {
                let jsonMessages = try JSONSerialization.data(withJSONObject: messageArray)
                let _messages = try JSONDecoder().decode([Message].self, from: jsonMessages)
                for message in _messages {
                    if !indexing && messages[message.id] == nil {
                        NotificationManager.shared.notifyMessage(message: message)
                    }
                    if let original = messages[message.id],
                       original.read != message.read {
                        PersistenceDatabase.MessageDatabase.updateReadStatus(message: message)
                    }
                    messages[message.id] = message
                }
                if totalPages == currentPage {
                    PersistenceDatabase.MessageDatabase.saveMessages(messages)
                    Photos.shared.loadForMessages()
                    Thread.mainBlock {
                        CentralisTabBarController.shared.messagesViewController.tabBarItem.badgeValue = "\(unread)"
                    }
                    return completion(nil, messages)
                } else {
                    let target = (currentPage ?? 1) + 1
                    updateMessages(totalPages: totalPages, currentPage: target, messages: messages, indexing: indexing, completion)
                }
            } catch {
                return completion(error.localizedDescription, nil)
            }
        }
    }
    
    public func markAsRead(_ completion: @escaping () -> Void) {
        EvanderNetworking.edulinkDict(method: "Communicator.MessageMarkRead", params: [.custom(key: "message_id", value: (Int(id!) ?? 0))]) { [weak self] _, _, error, _ in
            guard let self = self else { return }
            if error == nil {
                self.read = Date()
                PersistenceDatabase.MessageDatabase.updateReadStatus(message: self)
                Thread.mainBlock {
                    CentralisTabBarController.shared.messagesViewController.tabBarItem.badgeValue = "\(Self.unread)"
                }
                completion()
            }
        }
    }
    
    public static var unread: Int {
        var messages = Array(PersistenceDatabase.shared.messages.values)
        messages = messages.filter { $0.read == nil }
        return messages.count
    }
    
    public func getAttachment(attachment: Attachment, completion: @escaping (String?, URL?) -> Void) {
        EvanderNetworking.edulinkDict(method: "Communicator.AttachmentFetch", params: [
            .format(value: 2),
            .custom(key: "message_id", value: Int(self.id!) ?? -1),
            .custom(key: "attachment_id", value: Int(attachment.id) ?? -1)
        ]) { _, _, error, result in
            guard let result = result,
                  let _attachment = result["attachment"] as? [String: Any] else { return completion(error ?? "Unknown Error", nil) }
            if let content = _attachment["content"] as? String {
                guard let data = Data(base64Encoded: content) else { return completion("Failed to parse attachment data", nil) }
                try? data.write(to: attachment.fileDestination)
                return completion(nil, attachment.fileDestination)
            } else if let _url = _attachment["url"] as? String,
                      let url = URL(string: _url) {
                return completion(nil, url)
            }
            return completion("No Attachment was returned", nil)
        }
    }
}

public class Attachment: EdulinkBase {
    
    @Serialized(default: "Untitled File") var filename: String
    @Serialized(default: 0) var filesize: Int
    @Serialized(default: "application/pdf") var mime_type: String
    
    init(id: String, filename: String, filesize: Int, mime_type: String) {
        super.init()
        self.id = id
        self.filename = filename
        self.filesize = filesize
        self.mime_type = mime_type
    }
    
    required public init() {}
    
    public var fileDestination: URL {
        Message.attachmentFolder.appendingPathComponent("\(id!)_\(filename)")
    }
    
}

public class Sender: EdulinkBase {
    @Serialized(default: "employee") var type: String
    @Serialized(default: "Unknown Sender") var name: String
    
    init(id: String, type: String, name: String) {
        super.init()
        self.id = id
        self.type = type
        self.name = name
    }
    
    required public init() {}
    
}

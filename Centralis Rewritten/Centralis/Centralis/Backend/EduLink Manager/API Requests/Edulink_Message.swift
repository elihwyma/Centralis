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
    
    required public init() {
        fatalError("init() has not been implemented")
    }
    
    public class func updateMessages(totalPages: Int? = nil, currentPage: Int? = nil, messages: [String: Message] = PersistenceDatabase.shared.messages, _ completion: @escaping (String?, [String: Message]?) -> Void) {
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
                var hasAll = true
                for message in _messages {
                    if messages[message.id] == nil {
                        hasAll = false
                        messages[message.id] = message
                    }
                }
                if totalPages == currentPage || hasAll {
                    return completion(nil, messages)
                } else {
                    let target = (currentPage ?? 1) + 1
                    updateMessages(totalPages: totalPages, currentPage: target, messages: messages, completion)
                }
            } catch {
                return completion(error.localizedDescription, nil)
            }
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
    
    required public init() {
        fatalError("init() has not been implemented")
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
    
    required public init() {
        fatalError("init() has not been implemented")
    }
}

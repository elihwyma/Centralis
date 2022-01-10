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
    
    public class func updateMessages(totalPages: Int? = nil, currentPage: Int? = nil, messages: [Message] = [], _ completion: @escaping (String?, [Message]?) -> Void) {
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
                messages += _messages
                if totalPages == currentPage {
                    
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
}

public class Sender: EdulinkBase {
    @Serialized(default: "employee") var type: String
    @Serialized(default: "Unknown Sender") var name: String
}

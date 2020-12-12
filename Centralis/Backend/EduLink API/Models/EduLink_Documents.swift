//
//  EduLink_Documents.swift
//  Centralis
//
//  Created by Amy While on 12/12/2020.
//

import Foundation

class EduLink_Documents {
    public func documents() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Document")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Document\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedDocument, object: nil)
                    }
                    guard let documents = result["documents"] as? [[String : Any]] else {
                        NotificationCenter.default.post(name: .FailedDocument, object: nil)
                        return
                    }
                    EduLinkAPI.shared.documents.removeAll()
                    for document in documents {
                        var d = Document()
                        d.id = document["id"] as? Int ?? -1
                        d.summary = document["summary"] as? String ?? "Not Given"
                        d.type = document["type"] as? String ?? "Not Given"
                        d.last_updated = document["last_updated"] as? String ?? "Not Given"
                        EduLinkAPI.shared.documents.append(d)
                    }
                    NotificationCenter.default.post(name: .SucccesfulDocument, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
}

struct Document {
    var id: Int!
    var summary: String!
    var type: String!
    var last_updated: String!
    var data: String!
    var mime_type: String!
}

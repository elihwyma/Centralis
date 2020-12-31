//
//  EduLink_Documents.swift
//  Centralis
//
//  Created by Amy While on 12/12/2020.
//

import Foundation

class EduLink_Documents {
    
    class func documents(_ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Documents")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Documents\",\"params\":{\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let documents = result["documents"] as? [[String : Any]] else { return rootCompletion(false, "Unknown Error") }
            EduLinkAPI.shared.documents.removeAll()
            for document in documents {
                var d = Document()
                d.id = "\(document["id"] ?? "Not Given")"
                d.summary = document["summary"] as? String ?? "Not Given"
                d.type = document["type"] as? String ?? "Not Given"
                d.last_updated = document["last_updated"] as? String ?? "Not Given"
                EduLinkAPI.shared.documents.append(d)
            }
            rootCompletion(true, nil)
        })
    }
    
    class func document(_ document: Document, _ sender: TextViewController, _ rootCompletion: @escaping completionHandler) {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Document")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Document\",\"params\":{\"document_id\":\"\(document.id!)\",\"learner_id\":\"\(EduLinkAPI.shared.authorisedUser.id!)\",\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let r = result["result"] as? [String : Any], let data = r["document"] as? String, let index = EduLinkAPI.shared.documents.firstIndex(where: { $0.id == document.id }), let mime_type = r["mime_type"] as? String else { return rootCompletion(false, "Unknown Error") }
            EduLinkAPI.shared.documents[index].data = data; EduLinkAPI.shared.documents[index].mime_type = mime_type
            DispatchQueue.main.async {
                sender.performSegue(withIdentifier: "Centralis.DocumentWebView", sender: nil)
            }
            rootCompletion(true, nil)
        })
    }
}

struct Document {
    var id: String!
    var summary: String!
    var type: String!
    var last_updated: String!
    var data: String!
    var mime_type: String!
}

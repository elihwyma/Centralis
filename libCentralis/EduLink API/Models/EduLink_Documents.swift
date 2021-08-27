//
//  EduLink_Documents.swift
//  Centralis
//
//  Created by AW on 12/12/2020.
//

import Foundation

/// A model for working with Documents
public class EduLink_Documents {
    /// Retrieve a list of documents available to the user. For more documentation see `Document`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func documents(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ rootCompletion: @escaping completionHandler) {
        let params: [String: AnyEncodable] = [
            "learner_id" : AnyEncodable(learnerID)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Documents", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let documents = result["documents"] as? [[String : Any]] else { return rootCompletion(false, "Unknown Error") }
            var documentCache = [Document]()
            for document in documents {
                if let document = Document(document) {
                    documentCache.append(document)
                }
            }
            EduLinkAPI.shared.documents = documentCache
            rootCompletion(true, nil)
        })
    }
   
    /// Retrieve the document date and mime type
    /// - Parameters:
    ///   - document: The document the data is being parsed, for more documentation see `Document`
    ///   - rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func document(_ document: Document, _ rootCompletion: @escaping completionHandler) {
        let params: [String: AnyEncodable] = [
            "document_id" : AnyEncodable(document.id)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Document", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let r = result["result"] as? [String : Any], let data = r["document"] as? String, let mime_type = r["mime_type"] as? String else { return rootCompletion(false, "Unknown Error") }
            document.data = data
            document.mime_type = mime_type
            rootCompletion(true, nil)
        })
    }
}

public class Document {
    /// The ID of the document
    public var id: String
    /// The title of the document
    public var summary: String
    /// The format of the document
    public var type: String
    /// When the document was last updated
    public var last_updated: Date
    /// The data of the document
    public var data: String?
    /// The mime type of the document
    public var mime_type: String?
    
    init?(_ dict: [String: Any]) {
        guard let tmpID = dict["id"],
              let type = dict["type"] as? String,
              let tmpLastUpdated = dict["last_updated"] as? String,
              let lastUpdated = DateTime.date(tmpLastUpdated) else { return nil }
        self.id = String(describing: tmpID)
        self.summary = dict["summary"] as? String ?? "Not Given"
        self.type = type
        self.last_updated = lastUpdated
    }
}


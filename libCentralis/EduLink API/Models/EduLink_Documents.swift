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
        let params: [String : String] = [
            "learner_id" : learnerID
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Documents", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let documents = result["documents"] as? [[String : Any]] else { return rootCompletion(false, "Unknown Error") }
            var documentCache = [Document]()
            for document in documents {
                var d = Document()
                d.id = "\(document["id"] ?? "Not Given")"
                d.summary = document["summary"] as? String ?? "Not Given"
                d.type = document["type"] as? String ?? "Not Given"
                d.last_updated = document["last_updated"] as? String ?? "Not Given"
                documentCache.append(d)
            }
            if EduLinkAPI.shared.authorisedUser.id == learnerID { EduLinkAPI.shared.documents = documentCache } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    EduLinkAPI.shared.authorisedUser.children[index].documents = documentCache
                }
            }
            rootCompletion(true, nil)
        })
    }
    
    
    /// Retrieve the document date and mime type
    /// - Parameters:
    ///   - document: The document the data is being parsed, for more documentation see `Document`
    ///   - rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func document(_ document: Document, _ rootCompletion: @escaping completionHandler) {
        let learnerID = EduLinkAPI.shared.authorisedUser.id
        let params: [String : String] = [
            "document_id" : document.id
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Document", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let r = result["result"] as? [String : Any], let data = r["document"] as? String, let mime_type = r["mime_type"] as? String else { return rootCompletion(false, "Unknown Error") }
            if EduLinkAPI.shared.authorisedUser.id == learnerID {
                if let index = EduLinkAPI.shared.documents.firstIndex(where: {$0.id == document.id}) { EduLinkAPI.shared.documents[index].data = data; EduLinkAPI.shared.documents[index].mime_type = mime_type }
            } else {
                if let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == learnerID}) {
                    if let index2 = EduLinkAPI.shared.authorisedUser.children[index].documents.firstIndex(where: {$0.id == document.id}) { EduLinkAPI.shared.authorisedUser.children[index2].documents[index2].data = data; EduLinkAPI.shared.authorisedUser.children[index2].documents[index2].mime_type = mime_type }
                }
            }
            rootCompletion(true, nil)
        })
    }
}

/// The container for Document
public struct Document {
    /// The ID of the document
    public var id: String!
    /// The title of the document
    public var summary: String!
    /// The format of the document
    public var type: String!
    /// When the document was last updated
    public var last_updated: String!
    /// The data of the document
    public var data: String!
    /// The mime type of the document
    public var mime_type: String!
}

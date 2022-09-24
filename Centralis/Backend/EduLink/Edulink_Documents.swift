//
//  Edulink_Documents.swift
//  Centralis
//
//  Created by Somica on 04/02/2022.
//

import Foundation
import SerializedSwift
import Evander

public final class Document: EdulinkBase {
  
    @SerializedTransformable<DateConverter> var last_updated: Date?
    @Serialized var filename: String
    @Serialized var summary: String
    @Serialized var type: String
    var secondaryFilename: String?
    
    public static let documentsFolder = EvanderNetworking._cacheDirectory.appendingPathComponent("Documents")
    
    public var fileDestination: URL {
        Self.documentsFolder.appendingPathComponent("\(id!)_\(last_updated?.timeIntervalSince1970 ?? 0)_\(secondaryFilename ?? filename)")
    }
    
    public class func updateDocuments(_ completion: @escaping (String?, [Document]?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.Documents", params: [.learner_id]) { _, _, error, result in
            guard PermissionManager.contains(.documents) else { return completion(nil, []) }
            guard let result = result,
                  let documents = result["documents"] as? [[String: Any]],
                  let jsonDocuments = try? JSONSerialization.data(withJSONObject: documents) else { return completion(error ?? "Unknown Error", nil) }
            do {
                let documents = try JSONDecoder().decode([Document].self, from: jsonDocuments)
                PersistenceDatabase.DocumentDatabase.changes(documents: documents)
                return completion(nil, documents)
            } catch {
                return completion(error.localizedDescription, nil)
            }
        }
    }
    
    public func getDocument(completion: @escaping (String?, URL?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.Document", params: [
            .format(value: 2),
            .custom(key: "document_id", value: Int(id) ?? -1)
        ]) { [weak self] _, _, error, result  in
            guard let result = result,
                  let _document = result["result"] as? [String: Any],
                  let `self` = self else { return completion(error ?? "Unknown Error", nil) }
            if let content = _document["content"] as? String {
                guard let data = Data(base64Encoded: content) else { return completion("Failed to parse document data", nil) }
                try? data.write(to: self.fileDestination)
                return completion(nil, self.fileDestination)
            } else if let _url = _document["url"] as? String,
                      let url = URL(string: _url) {
                self.secondaryFilename = _document["filename"] as? String
                return completion(nil, url)
            }
            return completion("No Document was returned", nil)
        }
    }
    
}

public func == (lhs: Document, rhs: Document) -> Bool {
    lhs.id == rhs.id && lhs.last_updated == rhs.last_updated
}

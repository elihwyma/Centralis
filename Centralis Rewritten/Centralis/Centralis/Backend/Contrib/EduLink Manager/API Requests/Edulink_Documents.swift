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
    
    public class func updateHomework(indexing: Bool = false, _ completion: @escaping (String?, [Document]?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.Documents", params: [.learner_id]) { _, _, error, result in
            guard let result = result,
                  let documents = result["documents"] as? [[String: Any]],
                  let jsonDocuments = try? JSONSerialization.data(withJSONObject: documents) else { return completion(error ?? "Unknown Error", nil) }
            do {
                let documents = try JSONDecoder().decode([Document].self, from: jsonDocuments)
                if !indexing {
                    PersistenceDatabase.HomeworkDatabase.changes(newHomework: &allHomework)
                }
                return completion(nil, documents)
            } catch {
                return completion(error.localizedDescription, nil)
            }
        }
    }
    
}

//
//  Edulink_Links.swift
//  Centralis
//
//  Created by Amy While on 06/02/2022.
//

import Foundation
import Evander
import SerializedSwift

public final class Link: EdulinkBase {
    
    @Serialized var name: String
    @Serialized var url: URL
    @Serialized(default: 0) var position: Int
    
    public class func updateLinks(_ completion: @escaping (String?, [Link]?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.ExternalLinks", params: []) { _, _, error, result in
            guard PermissionManager.contains(.links) else { return completion(nil, []) }
            guard let result = result,
                  let links = result["links"] as? [[String: Any]],
                  let jsonLinks = try? JSONSerialization.data(withJSONObject: links) else { return completion(error ?? "Unknown Error", nil) }
            do {
                let links = try JSONDecoder().decode([Link].self, from: jsonLinks)
                PersistenceDatabase.LinkDatabase.changes(links: links)
                completion(error, links)
            } catch {
                return completion(error.localizedDescription, nil)
            }
        }
    }
}

public func == (lhs: Link, rhs: Link) -> Bool {
    lhs.id == rhs.id && lhs.url == rhs.url && lhs.position == rhs.position
}

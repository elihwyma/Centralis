//
//  EduLink_Links.swift
//  Centralis
//
//  Created by AW on 11/12/2020.
//

import Foundation

/// A model for retrieving links, 
public class EduLink_Links {
    /// Retrieve the links set by the school, for more documentation see `Link`
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func links(_ rootCompletion: @escaping completionHandler) {
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.ExternalLinks", completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let links = result["links"] as? [[String : Any]] else { return rootCompletion(false, "Unknown Error" )}
            let linkCache = links.compactMap({ Link($0 )})
            EduLinkAPI.shared.links = linkCache
            rootCompletion(true, nil)
        })
    }
}

/// A container for Links
public struct Link {
    /// The name of the link
    public var name: String
    /// The URL of the link
    public var link: String
    /// The image registered to the link
    public var image: Data?
    
    init?(_ dict: [String: Any]) {
        guard let name = dict["name"] as? String,
              let url = dict["url"] as? String else { return nil }
        self.name = name
        self.link = url
        if var data = dict["icon"] as? String {
            data = data.replacingOccurrences(of: "data:image/png;base64,", with: "")
            if let decodedData = Data(base64Encoded: data, options: .ignoreUnknownCharacters) {
                self.image = decodedData
            }
        }
    }
}

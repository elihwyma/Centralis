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
        let params: [String : String] = [
            "authtoken" : EduLinkAPI.shared.authorisedUser.authToken
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.ExternalLinks", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let links = result["links"] as? [[String : Any]] else { return rootCompletion(false, "Unknown Error" )}
            var linkCache = [Link]()
            for link in links {
                var l = Link()
                l.name = link["name"] as? String ?? "Not Found"
                l.link = link["url"] as? String ?? "Not Found"
                if var imageData = link["icon"] as? String {
                    imageData = imageData.replacingOccurrences(of: "data:image/png;base64,", with: "")
                    if let decodedData = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
                        l.image = decodedData
                    }
                }
                linkCache.append(l)
            }
            EduLinkAPI.shared.links = linkCache
            rootCompletion(true, nil)
        })
    }
}

/// A container for Links
public struct Link {
    /// The name of the link
    public var name: String!
    /// The URL of the link
    public var link: String!
    /// The image registered to the link
    public var image: Data!
}

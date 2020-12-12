//
//  EduLink_Links.swift
//  Centralis
//
//  Created by Amy While on 11/12/2020.
//

import UIKit

class EduLink_Links {
    public func links() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.ExternalLinks")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.ExternalLinks\",\"params\":{\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedLink, object: nil)
                        return
                    }
                    if let links = result["links"] as? [[String : Any]] {
                        EduLinkAPI.shared.links.removeAll()
                        for link in links {
                            var l = Link()
                            l.name = link["name"] as? String ?? "Not Found"
                            l.link = link["url"] as? String ?? "Not Found"
                            if var imageData = link["icon"] as? String {
                                imageData = imageData.replacingOccurrences(of: "data:image/png;base64,", with: "")
                                if let decodedData = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
                                    l.image = UIImage(data: decodedData)
                                } else {
                                    l.image = UIImage(systemName: "link.circle.fill")
                                }
                            } else {
                                l.image = UIImage(systemName: "link.circle.fill")
                            }
                            EduLinkAPI.shared.links.append(l)
                        }
                    } else {
                        NotificationCenter.default.post(name: .FailedLink, object: nil)
                    }
                    NotificationCenter.default.post(name: .SuccesfulLink, object: nil)
                } else {
                    NotificationCenter.default.post(name: .FailedLink, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
}

struct Link {
    var name: String!
    var link: String!
    var image: UIImage!
}

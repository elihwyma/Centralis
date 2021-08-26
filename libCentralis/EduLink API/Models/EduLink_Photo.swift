//
//  EduLink_Photo.swift
//  Centralis
//
//  Created by A W on 04/03/2021.
//

import Foundation

class EduLink_Photo {
    class func learner_photos(learners: [String], _ rootCompletion: @escaping completionHandler) {
        let params: [String : AnyEncodable] = [
            "learner_ids" : AnyEncodable(learners)
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.Document", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            guard let r = result["result"] as? [String : Any], let learner_photos = r["learner_photos"] as? [[String : Any]] else { return rootCompletion(false, "Unknown Error") }
            for photo in learner_photos {
                let imageData = photo["photo"] as? String ?? ""
                guard let id = photo["id"] as? String else { continue }
                if let decodedData = Data(base64Encoded: imageData, options: .ignoreUnknownCharacters) {
                    guard let index = EduLinkAPI.shared.authorisedUser.children.firstIndex(where: {$0.id == id}) else { continue }
                    EduLinkAPI.shared.authorisedUser.children[index].avatar = decodedData
                }
            }
            NotificationCenter.default.post(name: .LearnerImage, object: nil)
            rootCompletion(true, nil)
        })
    }
}

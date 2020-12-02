//
//  EduLink-Status.swift
//  Centralis
//
//  Created by Amy While on 02/12/2020.
//

import Foundation

class EduLink_Status {
    public func status() {
        let url = URL(string: "\(EduLinkAPI.shared.authorisedSchool.server!)?method=EduLink.Status")!
        let headers: [String : String] = ["Content-Type" : "application/json;charset=utf-8"]
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Status\",\"params\":{\"last_visible\":0,\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"\(UUID.shared.uuid)\",\"id\":\"1\"}"
        NetworkManager.shared.requestWithDict(url: url, method: "POST", headers: headers, jsonbody: body, completion: { (success, dict) -> Void in
            if success {
                if let result = dict["result"] as? [String : Any] {
                    if !(result["success"] as! Bool) {
                        NotificationCenter.default.post(name: .FailedStatus, object: nil)
                        return
                    }
                    EduLinkAPI.shared.status.new_messages = result["new_messages"] as? Int
                    EduLinkAPI.shared.status.new_forms = result["new_forms"] as? Int
                    NotificationCenter.default.post(name: .SuccesfulStatus, object: nil)
                } else {
                    NotificationCenter.default.post(name: .FailedStatus, object: nil)
                }
            } else {
                NotificationCenter.default.post(name: .NetworkError, object: nil)
            }
        })
    }
}

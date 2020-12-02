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
        let body = "{\"jsonrpc\":\"2.0\",\"method\":\"EduLink.Status\",\"params\":{\"last_visible\":0,\"authtoken\":\"\(EduLinkAPI.shared.authorisedUser.authToken!)\"},\"uuid\":\"FuckYouOvernetData\",\"id\":\"1\"}"
    }
}

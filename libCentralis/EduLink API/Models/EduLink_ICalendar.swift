//
//  EduLink_ICalendar.swift
//  Centralis
//
//  Created by Somica on 13/05/2021.
//

import Foundation

class EduLink_ICalendar {
    class public func calendar(rootCompletion: @escaping completionHandler) {
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.ICalendars", completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error Ocurred") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, "Unknown Error Ocurred") }
            if let exports = result["exports"] as? [String: Any],
               let personal = exports["personal"] as? [[String: Any]] {
                EduLinkAPI.shared.calendars = personal.compactMap({ iCal($0) })
            }
            rootCompletion(true, nil)
        })
    }
}

public struct iCal {
    var type: String
    var description: String
    var enabled: Bool
    var url: URL?
    
    init?(_ dict: [String: Any]) {
        guard let type = dict["type"] as? String,
              let description = dict["description"] as? String,
              let enabled = dict["enabled"] as? Bool else { return nil }
        self.type = type
        self.description = description
        self.enabled = enabled
        if let tmpURL = dict["url"] as? String,
           let url = URL(string: tmpURL) {
            self.url = url
        }
    }
}

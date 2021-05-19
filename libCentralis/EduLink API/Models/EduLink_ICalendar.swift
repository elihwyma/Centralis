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
            
            rootCompletion(true, nil)
        })
    }
}

public struct iCal {
    var type: String
    var description: String
    var enabled: Bool
    var url: URL
}

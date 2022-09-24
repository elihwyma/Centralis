//
//  Edulink_iCalendar.swift
//  Centralis
//
//  Created by Somica on 24/03/2022.
//

import Foundation
import SerializedSwift
import Evander

final public class ICalendar: Serializable {
    
    @Serialized(default: true) var enabled: Bool
    @Serialized var description: String
    @Serialized var type: String
    @Serialized var url: URL?
    
    required public init() {}
    
    public class func getCalendars(_ completion: @escaping (String?, [ICalendar]?) -> Void) {
        EvanderNetworking.edulinkDict(method: "EduLink.ICalendars", params: []) { _, _, error, result in
            guard let result = result,
                  let exports = result["exports"] as? [String: Any],
                  let personal = exports["personal"] as? [[String: AnyHashable?]],
                  let jsonData = try? JSONSerialization.data(withJSONObject: personal) else {
                      return completion(error ?? "Unknown Error", nil) }
            do {
                let calendars = try JSONDecoder().decode([ICalendar].self, from: jsonData)
                completion(nil, calendars)
            } catch {
                completion(error.localizedDescription, nil)
            }
        }
    }
    
}

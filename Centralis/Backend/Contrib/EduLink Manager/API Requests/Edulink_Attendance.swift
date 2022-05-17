//
//  Edulink_Attendance.swift
//  Centralis
//
//  Created by Somica on 04/04/2022.
//

import Foundation
import SerializedSwift
import Evander
import CoreGraphics

final public class Attendance: Serializable {
    
    enum Colours {
        case present
        case unauthorised
        case absent
        case late
     
        var rawValue: CGColor {
            switch self {
            case .present: return #colorLiteral(red: 0.3568627451, green: 0.5490196078, blue: 0.3529411765, alpha: 1) //5B8C5A
            case .unauthorised: return #colorLiteral(red: 0.2470588235, green: 0.5333333333, blue: 0.7725490196, alpha: 1) //3F88C5
            case .absent: return #colorLiteral(red: 0.9411764706, green: 0.5294117647, blue: 0, alpha: 1) //F08700
            case .late: return #colorLiteral(red: 0.8901960784, green: 0.3960784314, blue: 0.3568627451, alpha: 1) //E3655B 
            }
        }
    }
    
    @Serialized(default: []) var lesson: [Lesson]
    @Serialized(default: []) var statutory: [Lesson]
    
    public struct Exception: Serializable {
        @SerializedTransformable<DateConverter> var date: Date?
        @Serialized(default: "Not Provided") var description: String
        @Serialized(default: "Not Provided") var type: String
        @Serialized(default: "Not Provided") var period: String
        
        public init() {}
    }
    
    public struct Values: Serializable {
        @Serialized(default: 0) var present: Int
        @Serialized(default: 0) var absent: Int
        @Serialized(default: 0) var late: Int
        @Serialized(default: 0) var unauthorised: Int
        
        public init() {}
    }
    
    public class Lesson: Serializable {
        @Serialized(alternateKey: "month") var lesson: String
        @Serialized(default: []) var exceptions: [Exception]
        @Serialized var values: Values
        
        required public init() {}
    }
    
    public class func updateAttendance(_ completion: @escaping (String?, Attendance?) -> Void) {
        guard PermissionManager.contains(.attendance) else { return completion(nil, Attendance()) }
        EvanderNetworking.edulinkDict(method: "EduLink.Attendance", params: [
            .learner_id,
            .format(value: 3)
        ]) { _, _, error, result in
            guard let result = result,
                  let jsonData = try? JSONSerialization.data(withJSONObject: result) else {
                      return completion(error ?? "Unknown Error", nil) }
            do {
                let attendance = try JSONDecoder().decode(Attendance.self, from: jsonData)
                completion(nil, attendance)
            } catch {
                completion(error.localizedDescription, nil)
            }
        }
    }
    
    public init() {}
    
    public init(lesson: [Lesson] = [], statutory: [Lesson] = []) {
        self.lesson = lesson
        self.statutory = statutory
    }
    
}

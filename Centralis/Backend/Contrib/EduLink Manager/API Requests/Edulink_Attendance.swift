//
//  Edulink_Attendance.swift
//  Centralis
//
//  Created by Amy While on 04/04/2022.
//

import Foundation
import SerializedSwift
import Evander

final public class Attendance {
    
    public struct Values: Serializable {
        
        @Serialized var present: Int
        @Serialized var unauthorised: Int
        @Serialized var absent: Int
        @Serialized var late: Int
        
        public init() {}
        
    }
    
    public struct Exception: Serializable {
        
        @SerializedTransformable<DateConverter> var date: Date?
        @Serialized(default: "Non Provided") var description: String
        @Serialized(default: "Non Provided") var type: String
        @Serialized(default: "Non Provided") var period: String
        
        public init() {}
        
    }
    
}

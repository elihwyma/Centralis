//
//  EdulinkStatus.swift
//  Centralis
//
//  Created by Somica on 23/11/2021.
//

import Foundation
import SerializedSwift

final public class Status: Serializable {
    
    @Serialized var session: Session
    @Serialized var new_messages: Int
    
    public struct StatusLesson: Serializable {
        public init() {}
    }
    
    required public init() {}
    
}

public struct Session: Serializable {
    @Serialized var expires: Int
    
    public init() {}
}

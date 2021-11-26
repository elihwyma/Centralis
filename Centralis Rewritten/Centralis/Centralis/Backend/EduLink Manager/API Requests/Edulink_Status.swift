//
//  EdulinkStatus.swift
//  Centralis
//
//  Created by Somica on 23/11/2021.
//

import Foundation
import SerializedSwift
import Evander

public final class Status: Serializable {
    
    @Serialized var session: Session
    @Serialized var new_messages: Int
    
    public struct StatusLesson: Serializable {
        public init() {}
    }
    
    required public init() {}
}

public struct Session: Serializable {
    
    @Serialized var expires: Int {
        mutating didSet {
            expiresDate = Date().addingTimeInterval(TimeInterval(expires))
        }
    }
    public var expiresDate: Date
    
    public init() {
        expiresDate = Date()
    }
    
    public init(from decoder: Decoder) throws {
        self.init()
        try decode(from: decoder)
        
        EdulinkManager.shared.session = self
    }
}

public final class Ping {
    
    public class func ping(_ completion: @escaping (String) -> ()) {
        EvanderNetworking.edulinkDict(method: "EduLink.Ping", params: []) { success, _, message, _ in
            if success {
                EdulinkManager.shared.session?.expires = 1800
                return
            } else if let login = EdulinkManager.shared.authenticatedUser?.login {
                LoginManager.login(login) { error, _ in
                    if let error = error {
                        return completion(error)
                    }
                }
            } else {
                return completion("Unable to do anything wtf?")
            }
        }
    }
    
}


//
//  UserLogin.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift

final public class UserLogin: Serializable, Equatable {
    
    @Serialized public var username: String
    @Serialized public var password: String
    
    @Serialized public var server: URL
    @Serialized public var schoolID: String
    @Serialized public var schoolCode: String
    
    public init(server: URL, schoolID: String, schoolCode: String, username: String, password: String) {
        self.server = server
        self.schoolID = schoolID
        self.schoolCode = schoolCode
        self.username = username
        self.password = password
    }
    
    public init() {}
    
}

public func == (lhs: UserLogin, rhs: UserLogin) -> Bool {
    lhs.username == rhs.username && lhs.schoolCode == rhs.schoolCode
}

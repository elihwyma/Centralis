//
//  UserLogin.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift

final public class UserLogin: Serializable, Equatable {
    
    @Serialized public var forename: String
    @Serialized public var surname: String
    @Serialized public var username: String
    @Serialized public var password: String
    @Serialized public var image: Data?
    
    @Serialized public var server: URL
    @Serialized public var schoolName: String
    @Serialized public var schoolID: String
    @Serialized public var schoolCode: String
    
    public init(forename: String, surname: String, image: Data?, server: URL, schoolName: String, schoolID: String, schoolCode: String) {
        self.forename = forename
        self.surname = surname
        self.image = image
        self.server = server
        self.schoolName = schoolName
        self.schoolID = schoolID
        self.schoolCode = schoolCode
    }
    
    public init() {}
    
}

public func == (lhs: UserLogin, rhs: UserLogin) -> Bool {
    lhs.username == rhs.username && lhs.schoolCode == rhs.schoolCode
}

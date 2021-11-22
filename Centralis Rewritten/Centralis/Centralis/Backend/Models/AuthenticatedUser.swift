//
//  AuthenticatedUser.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation

final public class AuthenticatedUser {
    
    public var login: UserLogin
    public var authToken: String
    public var learner_id: String
    public var school_details: SchoolDetails?
    
    public init(login: UserLogin, authToken: String, learner_id: String) {
        self.login = login
        self.authToken = authToken
        self.learner_id = learner_id
    }

}

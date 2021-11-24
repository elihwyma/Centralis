//
//  AuthenticatedUser.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift

final public class AuthenticatedUser: Serializable {
    
    public var login: UserLogin?
    @Serialized var establishment: Establishment
    @Serialized var user: User
    @Serialized var personal_menu: [EdulinkStore]
    @Serialized var authtoken: String
    @Serialized(default: false) var can_create_messages: Bool
 
    required public init() {}
    
    public lazy var learner_id: String = {
        user.id
    }()
}
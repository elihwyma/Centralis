//
//  EdulinkManager.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation

final public class EdulinkManager {
    
    static var shared = EdulinkManager()
    public var authenticatedUser: AuthenticatedUser?
    public var status: Status?
    
    public func signout() {
        Self.shared = EdulinkManager()
    }
}

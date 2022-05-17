//
//  UserDefaults+Extension.swift
//  Centralis
//
//  Created by Somica on 04/05/2022.
//

import Foundation

extension UserDefaults {
    
    public func removeAllKeys() {
        let dict = dictionaryRepresentation()
        for key in dict.keys {
            removeObject(forKey: key)
        }
        
        PersistenceDatabase.domainDefaults.set(currentResetVersion, forKey: "Version")
    }
    
}

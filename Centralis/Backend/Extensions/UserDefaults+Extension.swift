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
            if key.hasPrefix("Theme.") { continue }
            if key == "Version" { continue }
            removeObject(forKey: key)
        }
    }
    
}

//
//  Thread+Extensions.swift
//  Centralis
//
//  Created by Andromeda on 27/11/2021.
//

import Foundation

public extension Thread {
    
    class func mainBlock(_ block: () -> Void) {
        if isMainThread {
            block()
        } else {
            DispatchQueue.main.sync {
                block()
            }
        }
    }
    
}

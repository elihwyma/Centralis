//
//  UUID.swift
//  Centralis
//
//  Created by Amy While on 02/12/2020.
//

import Foundation

class UUID {
    static let shared = UUID()
    
    private func randomString(_ length: Int) -> String {
      let letters = "abcdef0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

    public var uuid: String {
        return "\(randomString(8))-\(randomString(4))-\(randomString(4))-\(randomString(4))-\(randomString(12))"
    }
}

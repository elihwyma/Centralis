//
//  UUID.swift
//  Centralis
//
//  Created by AW on 02/12/2020.
//

import Foundation

internal class UUID {

    class private func randomString(_ length: Int) -> String {
      let letters = "abcdef0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }

    class internal var uuid: String {
        return "\(randomString(8))-\(randomString(4))-\(randomString(4))-\(randomString(4))-\(randomString(12))"
    }
}

//
//  Transformers.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift
import Evander

public class IDTransformer: Transformable {
    
    public static func transformToJSON(value: String?) -> IDConverter? {
        return .init(value: value)
    }
    
    public static func transformFromJSON(value: IDConverter?) -> String? {
        return value?.value
    }
    
    public static func transformToJSON(value: String?) -> Any? {
        value
    }
    
    public typealias From = IDConverter
    
    public typealias To = String

}

public class Base64: Transformable {
    
    public static func transformFromJSON(value: String?) -> Data? {
        if let value = value {
            return Data(base64Encoded: value, options: .ignoreUnknownCharacters)
        }
        return nil
    }
    
    public static func transformToJSON(value: Data?) -> String? {
        if let value = value {
            return value.base64EncodedString()
        }
        return nil
    }
    
    public typealias From = String
    
    public typealias To = Data
    
}

public struct IDConverter: Codable, Equatable, Hashable {
    public var value: String
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            value = x
            return
        }
        if let x = try? container.decode(Int.self) {
            value = String(x)
            return
        }
        throw DecodingError.typeMismatch(IDConverter.self, .init(codingPath: decoder.codingPath, debugDescription: "Failed to Parse You Fuckers"))
    }
    
    public init?(value: String?) {
        if let value = value {
            self.value = value
        } else {
            return nil
        }
    }
}

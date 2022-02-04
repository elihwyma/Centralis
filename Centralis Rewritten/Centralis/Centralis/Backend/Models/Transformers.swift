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
        .init(value: value)
    }
    
    public static func transformFromJSON(value: IDConverter?) -> String? {
        return value?.value
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
        let error = DecodingError.typeMismatch(IDConverter.self, .init(codingPath: decoder.codingPath, debugDescription: "Failed to Parse You Fuckers"))
        throw error
    }
    
    public init?(value: String?) {
        if let value = value {
            self.value = value
        } else {
            return nil
        }
    }
}

public class DateConverter: Transformable {
    
    public static func transformFromJSON(value: String?) -> Date? {
        guard let string = value else { return nil }
        var dateComponents = DateComponents()
        if string.contains(" ") {
            // Example "2019-05-14 07:52:16"
            let splitParts = string.split(separator: " ")
            guard splitParts.count == 2 else { return nil }
            let splitDay = String(splitParts[0]).split(separator: "-")
            guard splitDay.count == 3 else { return nil }
            dateComponents.year = Int(splitDay[0])
            dateComponents.month = Int(splitDay[1])
            dateComponents.day = Int(splitDay[2])
            dateComponents.timeZone = TimeZone.current
            
            let splitTime = String(splitParts[1]).split(separator: ":")
            guard splitTime.count == 3 || splitTime.count == 2 else { return nil }
            dateComponents.hour = Int(splitTime[0])
            dateComponents.minute = Int(splitTime[1])
            if splitTime.count == 3 {
                dateComponents.second = Int(splitTime[2])
            }
        } else if string.contains("-") {
            // Example "2019-05-20"
            let splitDay = string.split(separator: "-")
            guard splitDay.count == 3 else { return nil }
            
            dateComponents.year = Int(splitDay[0])
            dateComponents.month = Int(splitDay[1])
            dateComponents.day = Int(splitDay[2])
            dateComponents.timeZone = TimeZone.current
        }
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)
        return date
    }
    
    public static func transformToJSON(value: Date?) -> String? {
        return nil
    }
        
    public typealias From = String
    
    public typealias To = Date
}

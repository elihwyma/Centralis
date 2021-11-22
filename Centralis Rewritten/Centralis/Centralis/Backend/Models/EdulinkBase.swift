//
//  ID.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift

public class EdulinkBase: Serializable {
    
    @SerializedTransformable<IDTransformer> var id: String!
    
    required public init() {}
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        try decode(from: decoder)
        
        if id == nil {
            id = "-1"
        }
    }
}

public class EdulinkStore: EdulinkBase {
    @Serialized var name: String
}

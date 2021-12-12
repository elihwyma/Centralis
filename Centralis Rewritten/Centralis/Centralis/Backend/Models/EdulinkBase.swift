//
//  ID.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift

public class EdulinkBase: Serializable, Equatable, Identifiable {
    
    @SerializedTransformable<IDTransformer>(fallback: "-1") var id: String!
    
    required public init() {}
}

public class EdulinkStore: EdulinkBase {
    @Serialized var name: String
}

public func == (lhs: EdulinkBase, rhs: EdulinkBase) -> Bool {
    lhs.id == rhs.id
}

//
//  User.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift


final public class User: EdulinkBase {
    
    @Serialized var community_group_id: String
    @SerializedTransformable<IDTransformer> var establishment_id: String!
    @Serialized var forename: String
    @Serialized var form_group_id: String
    @Serialized var gender: String
    @Serialized var surname: String
    @Serialized var title: String?
    @Serialized var username: String
    @Serialized var year_group_ip: String
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        try decode(from: decoder)
        
        if establishment_id == nil {
            establishment_id = "-1"
        }
    }
}

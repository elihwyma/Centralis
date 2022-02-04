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
    @SerializedTransformableString<IDTransformer>(fallback: "-1") var establishment_id: String!
    @Serialized var forename: String
    @Serialized var form_group_id: String
    @Serialized var gender: String
    @Serialized var surname: String
    @Serialized var title: String?
    @Serialized var username: String
    @Serialized var year_group_id: String
    
}

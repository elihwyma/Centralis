//
//  User.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift


final public class User: EdulinkBase {
    
    @SerializedTransformableString<IDTransformer>(fallback: "-1") var community_group_id: String!
    @SerializedTransformableString<IDTransformer>(fallback: "-1") var establishment_id: String!
    @Serialized var forename: String
    @SerializedTransformableString<IDTransformer>(fallback: "-1") var form_group_id: String!
    @Serialized(default: "Unknown") var gender: String
    @Serialized var surname: String
    @Serialized var title: String?
    @Serialized(default: "DemoUser") var username: String
    @SerializedTransformableString<IDTransformer>(fallback: "-1") var year_group_id: String!
    
}

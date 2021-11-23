//
//  SchoolDetails.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import SerializedSwift

final public class LoginEstablishment: EdulinkBase {
    
    @Serialized var name: String
    @SerializedTransformable<Base64> var logo: Data?
    @Serialized(default: false) var idp_only: Bool
    @Serialized var idp_login: IDPLogin?
    
}

final public class SchoolDetails {
    public var server: URL
    public var school_id: String
    public var code: String
    public var establishment: LoginEstablishment
    
    public init(server: URL, school_id: String, code: String, establishment: LoginEstablishment) {
        self.server = server
        self.school_id = school_id
        self.code = code
        self.establishment = establishment
    }
}

public struct IDPLogin: Serializable {
    
    @Serialized var google: URL?
    
    public init() {}
    
}

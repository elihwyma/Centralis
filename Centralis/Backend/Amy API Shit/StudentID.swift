//
//  StudentID.swift
//  Centralis
//
//  Created by Amy While on 01/09/2022.
//

import Foundation
import Evander

final public class StudentID {
    
    public class func generateID(dob: Date, graduationYear: String, completion: @escaping (String?, Data?) -> Void) {
        let dobString = ISO8601DateFormatter().string(from: dob)
        
        guard let authorisedUser = EdulinkManager.shared.authenticatedUser else { return completion("Could not load authenticated user", nil) }
        let studentid = authorisedUser.learner_id
        let name = authorisedUser.user.forename + " " + authorisedUser.user.surname
        
        var json: [String: AnyHashable] = [
            "schoolname": authorisedUser.establishment.name,
            "name": name,
            "studentid": studentid,
            "dob": dobString,
            "graduationyear": graduationYear
        ]
        if let data = authorisedUser.establishment.logo {
            let b64 = data.base64EncodedString()
            json["schoolimage"] = b64
        }
        EvanderNetworking.request(url: "https://api.anamy.gay/centralis/studentid", type: Data.self, method: "POST", json: json) { _, status, error, passdata in
            completion(error?.localizedDescription, passdata)
        }
    }

}

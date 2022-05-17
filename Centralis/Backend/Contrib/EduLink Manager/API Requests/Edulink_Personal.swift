//
//  Edulink_Personal.swift
//  Centralis
//
//  Created by Somica on 04/05/2022.
//

import Foundation
import Evander
import SerializedSwift

final public class Personal: EdulinkBase {
    
    @Serialized var address: String?
    @SerializedTransformable<DateConverter> var admission_date: Date?
    @SerializedTransformableString<IDTransformer>(fallback: "-1") var admission_number: String?
    @SerializedTransformable<DateConverter> var date_of_birth: Date?
    @Serialized var email: String?
    @Serialized var forename: String?
    @Serialized var form_group: FormGroup?
    @Serialized var gender: String?
    @Serialized var house_group: EdulinkStore?
    @Serialized var mobile_phone: String?
    @Serialized var phone: String?
    @Serialized var post_code: String?
    @Serialized var status: String?
    @Serialized var surname: String?
    @SerializedTransformableString<IDTransformer>(fallback: "-1") var unique_learner_number: String?
    @SerializedTransformableString<IDTransformer>(fallback: "-1") var unique_pupil_number: String?
    @Serialized var year_group: EdulinkStore?
    
    struct FormGroup: Serializable {
    
        @Serialized var employee: Employee?
        @SerializedTransformableString<IDTransformer>(fallback: "-1") var id: String?
        @Serialized var name: String?
        @Serialized var room: Room?
        
        class Room: EdulinkStore {
            @Serialized var code: String?
        }
    }
    
    public class func updatePersonal(_ completion: @escaping (String?, Personal?) -> Void) {
        guard PermissionManager.contains(.account) else { return completion(nil, Personal()) }
        EvanderNetworking.edulinkDict(method: "EduLink.Personal", params: [.learner_id]) { _, _, error, result in
            guard let result = result,
                  let personal = result["personal"],
                  let jsonData = try? JSONSerialization.data(withJSONObject: personal) else {
                      return completion(error ?? "Unknown Error", nil) }
            do {
                let personal = try JSONDecoder().decode(Personal.self, from: jsonData)
                PersistenceDatabase.PersonalDatabase.save(personal: personal)
                completion(nil, personal)
            } catch {
                completion(error.localizedDescription, nil)
            }
        }
    }
    
    required public init() {
        
    }
    
}

struct Employee: Serializable {
    
    @Serialized var forename: String?
    @Serialized var surname: String?
    @Serialized var title: String?
    @SerializedTransformableString<IDTransformer>(fallback: "-1") var id: String?

    func name() -> String {
        var comp = [String]()
        if let title = title {
            comp.append(title)
        }
        if let forename = forename {
            comp.append(forename)
        }
        if let surname = surname {
            comp.append(surname)
        }
        return comp.joined(separator: " ")
    }
}

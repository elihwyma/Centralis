//
//  Edulink_Register.swift
//  Centralis
//
//  Created by AW on 18/12/2020.
//

import Foundation
import CoreGraphics

/// The model for handling the register
public class EduLink_Register {
    /// Retrieve the register codes for the current school. Are used in Attendance
    /// - Parameter rootCompletion: The completion handler, for more documentation see `completionHandler`
    class public func registerCodes(learnerID: String = EduLinkAPI.shared.authorisedUser.id, _ rootCompletion: @escaping completionHandler) {
        let params: [String : String] = [
            "learner_id" : learnerID
        ]
        NetworkManager.requestWithDict(url: nil, requestMethod: "EduLink.RegisterCodes", params: params, completion: { (success, dict) -> Void in
            if !success { return rootCompletion(false, "Network Error") }
            guard let result = dict["result"] as? [String : Any] else { return rootCompletion(false, "Unknown Error") }
            if !(result["success"] as? Bool ?? false) { return rootCompletion(false, (result["error"] as? String ?? "Unknown Error")) }
            let c = ColourConverter()
            if let lesson_codes = result["lesson_codes"] as? [[String : Any]] {
                EduLinkAPI.shared.authorisedSchool.schoolInfo.lesson_codes.removeAll()
                for lesson_code in lesson_codes {
                    var lc = RegisterCode()
                    lc.code = lesson_code["code"] as? String ?? "Not Given"
                    lc.active = lesson_code["active"] as? Bool ?? false
                    lc.name = lesson_code["name"] as? String ?? "Not Given"
                    lc.is_authorised_absence = lesson_code["is_authorised_absence"] as? Bool ?? false
                    lc.is_statistical = lesson_code["is_statistical"] as? Bool ?? false
                    lc.is_late = lesson_code["is_late"] as? Bool ?? false
                    lc.present = lesson_code["present"] as? Bool ?? false
                    lc.colour = c.colourFromString(lc.name)
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.lesson_codes.append(lc)
                }
            }
            if let statutory_codes = result["statutory_codes"] as? [[String : Any]] {
                EduLinkAPI.shared.authorisedSchool.schoolInfo.statutory_codes.removeAll()
                for statuory_code in statutory_codes {
                    var st = RegisterCode()
                    st.code = statuory_code["code"] as? String ?? "Not Given"
                    st.active = statuory_code["active"] as? Bool ?? false
                    st.name = statuory_code["name"] as? String ?? "Not Given"
                    st.is_authorised_absence = statuory_code["is_authorised_absence"] as? Bool ?? false
                    st.is_statistical = statuory_code["is_statistical"] as? Bool ?? false
                    st.is_late = statuory_code["is_late"] as? Bool ?? false
                    st.present = statuory_code["present"] as? Bool ?? false
                    st.colour = c.colourFromString(st.name)
                    EduLinkAPI.shared.authorisedSchool.schoolInfo.statutory_codes.append(st)
                }
            }
            rootCompletion(true, nil)
        })
    }
}

/// A container for RegisterCode
public struct RegisterCode {
    /// The code
    public var code: String!
    /// If the code is actively being used
    public var active: Bool!
    /// The name of the code
    public var name: String!
    /// The type of code
    public var type: String!
    /// If the code is classed as an authorised_absence
    public var is_authorised_absence: Bool!
    /// If the code is included in attendance statistics
    public var is_statistical: Bool!
    /// If the code is a statistical late
    public var is_late: Bool!
    /// If the code is for a present user
    public var present: Bool!
    /// The colour generated for the code. The colour is generated based on it's code, so is always the same
    public var colour: CGColor!
}

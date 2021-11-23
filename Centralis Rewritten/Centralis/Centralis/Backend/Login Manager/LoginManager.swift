//
//  LoginManager.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import Foundation
import Evander

public final class LoginManager {
    
    static public let shared = LoginManager()
    public var logins = [UserLogin]()
    
    @discardableResult public func loadLogins() -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : "Centralis.SavedLogins",
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecAttrAccessGroup as String: "group.amywhile.centralis",
            kSecMatchLimit as String  : kSecMatchLimitOne ]
        
        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == noErr,
              let data = dataTypeRef as? Data else { return status }
        self.logins = (try? JSONDecoder().decode([UserLogin].self, from: data)) ?? []
        return status
    }
    
    @discardableResult public func saveLogins() -> OSStatus {
        let encoded = (try? JSONEncoder().encode(logins)) ?? Data()
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : "Centralis.SavedLogins",
            kSecAttrAccessGroup as String: "group.amywhile.centralis",
            kSecValueData as String: encoded ]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }
    
    @discardableResult public func remove(login: UserLogin) -> OSStatus {
        logins.removeAll { $0 == login }
        return saveLogins()
    }
    
    @discardableResult public func save(login: UserLogin) -> OSStatus {
        logins.insert(login, at: 0)
        return saveLogins()
    }
    
    public init() {
        loadLogins()
    }
    
    public class func loadSchool(from code: String, _ completion: @escaping (String?, SchoolDetails?) -> Void) {
        let url = URL(string: "https://provisioning.edulinkone.com")!
        EvanderNetworking.edulinkDict(url: url, method: "School.FromCode", params: [.custom(key: "code", value: code)]) { _, _, error, result in
            guard let result = result,
                  let school = result["school"] as? [String: Any],
                  let _server = school["server"] as? String,
                  let server = URL(string: _server),
                  let _school_id = school["school_id"] else {
                return completion(error?.localizedDescription ?? "Unknown Error", nil)
            }
            let school_id = String(describing: _school_id)
            EvanderNetworking.edulinkDict(url: server, method: "EduLink.SchoolDetails", params: [.custom(key: "establishment_id", value: school_id),
                                                                                                 .custom(key: "from_app", value: false)]) { _, _, error, result in
                guard let result = result,
                      let _establishment = result["establishment"] as? [String: Any],
                      let jsonData = try? JSONSerialization.data(withJSONObject: _establishment) else {
                  return completion(error?.localizedDescription ?? "Unknown Error", nil)
                }
                let establishment: LoginEstablishment
                do {
                    establishment = try JSONDecoder().decode(LoginEstablishment.self, from: jsonData)
                } catch {
                    return completion(error.localizedDescription, nil)
                }
                completion(nil, SchoolDetails(server: server, school_id: school_id, code: code, establishment: establishment))
            }
        }
    }
    
    public class func login(_ login: UserLogin, _ completion: @escaping (String?, AuthenticatedUser?) -> Void) {
        EvanderNetworking.edulinkDict(url: login.server, method: "EduLink.Login", params: [
            .custom(key: "establishment_id", value: login.schoolID),
            .custom(key: "fcm_token_old", value: "none"),
            .custom(key: "from_app", value: false),
            .custom(key: "password", value: login.password),
            .custom(key: "username", value: login.username)]) { _, _, error, result in
                guard let result = result,
                      let jsonData = try? JSONSerialization.data(withJSONObject: result) else {
                   return completion(error ?? "Unknown Error", nil)
                }
                do {
                    let user = try JSONDecoder().decode(AuthenticatedUser.self, from: jsonData)
                    return completion(nil, user)
                } catch {
                    return completion(error.localizedDescription, nil)
                }
        }
    }
}

//
//  LoginManager.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import UIKit
import Evander

public final class LoginManager {
    
    static let appIdentifierPrefix = Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String
        
    public class func loadLogin() -> (OSStatus, UserLogin?) {
        let query: [String: Any] = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : "Centralis.SavedLogins",
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecAttrAccessGroup as String: "\(appIdentifierPrefix)group.amywhile.centralis",
            kSecMatchLimit as String  : kSecMatchLimitOne ]
        
        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == noErr,
              let data = dataTypeRef as? Data else { return (status, nil) }
        return (status, try? JSONDecoder().decode(UserLogin.self, from: data))
    }

    @discardableResult public class func save(login: UserLogin?) -> OSStatus {
        if let login = login  {
            let encoded = (try? JSONEncoder().encode(login)) ?? Data()
            let query: [String: Any] = [
                kSecClass as String       : kSecClassGenericPassword as String,
                kSecAttrAccount as String : "Centralis.SavedLogins",
                kSecAttrAccessGroup as String: "\(appIdentifierPrefix)group.amywhile.centralis",
                kSecValueData as String: encoded ]

            SecItemDelete(query as CFDictionary)
            return SecItemAdd(query as CFDictionary, nil)
        } else {
            let query: [String: Any] = [
                kSecClass as String       : kSecClassGenericPassword as String,
                kSecAttrAccount as String : "Centralis.SavedLogins",
                kSecAttrAccessGroup as String: "\(appIdentifierPrefix)group.amywhile.centralis" ]
            Self.cacheUser = nil
            return SecItemDelete(query as CFDictionary)
        }
    }
    
    public static var cacheUser: AuthenticatedUser? {
        get {
            let query: [String: Any] = [
                kSecClass as String       : kSecClassGenericPassword,
                kSecAttrAccount as String : "Centralis.CachedUser",
                kSecReturnData as String  : kCFBooleanTrue!,
                kSecAttrAccessGroup as String: "\(appIdentifierPrefix)group.amywhile.centralis",
                kSecMatchLimit as String  : kSecMatchLimitOne ]
            
            var dataTypeRef: AnyObject? = nil

            let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            
            guard status == noErr,
                  let data = dataTypeRef as? Data else { return nil }
            return try? JSONDecoder().decode(AuthenticatedUser.self, from: data)
        }
        set(login) {
            if let login = login {
                let encoded = (try? JSONEncoder().encode(login)) ?? Data()
                let query: [String: Any] = [
                    kSecClass as String       : kSecClassGenericPassword as String,
                    kSecAttrAccount as String : "Centralis.CachedUser",
                    kSecAttrAccessGroup as String: "\(appIdentifierPrefix)group.amywhile.centralis",
                    kSecValueData as String: encoded ]
                SecItemDelete(query as CFDictionary)
                SecItemAdd(query as CFDictionary, nil)
            } else {
                let query: [String: Any] = [
                    kSecClass as String       : kSecClassGenericPassword as String,
                    kSecAttrAccount as String : "Centralis.CachedUser",
                    kSecAttrAccessGroup as String: "\(appIdentifierPrefix)group.amywhile.centralis"]
                SecItemDelete(query as CFDictionary)
            }
        }
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
        
    public class func login(_ login: UserLogin, _indexBypass: Bool = false, _ completion: @escaping (String?, AuthenticatedUser?) -> Void) {
        func handleIndex() {
            if !_indexBypass {
                if !PersistenceDatabase.shared.hasIndexed {
                    _ = try? PersistenceDatabase.shared.resetDatabase()
                    Thread.mainBlock {
                        (UIApplication.shared.delegate as! AppDelegate).setRootViewController(IndexingViewController())
                    }
                } else {
                    PersistenceDatabase.backgroundRefresh {}
                }
            }
        }
        func _login() {
            let dict: [String: AnyHashable] = [
                "format": 2,
                "git_sha": "84e0228c54d65a8e79aa8dda48095d307c6049df",
                "version": "4.0.48"
            ]
            EvanderNetworking.edulinkDict(url: login.server, method: "EduLink.Login", params: [
                .custom(key: "establishment_id", value: login.schoolID),
                .custom(key: "fcm_token_old", value: "none"),
                .custom(key: "from_app", value: false),
                .custom(key: "password", value: login.password),
                .custom(key: "username", value: login.username),
                .custom(key: "ui_info", value: dict)]) { _, _, error, result in
                    guard let result = result,
                          let jsonData = try? JSONSerialization.data(withJSONObject: result) else {
                       return completion(error ?? "Unknown Error", nil)
                    }
                    do {
                        let user = try JSONDecoder().decode(AuthenticatedUser.self, from: jsonData)
                        user.server = login.server
                        user.login = login
                        EdulinkManager.shared.authenticatedUser = user
                        cacheUser = user
                        handleIndex()
                        return completion(nil, user)
                    } catch {
                        return completion(error.localizedDescription, nil)
                    }
            }
        }
        if let cacheUser = cacheUser {
            EdulinkManager.shared.authenticatedUser = cacheUser
            Ping.ping { error, success in
                if success {
                    handleIndex()
                    return completion(nil, cacheUser)
                }
                _login()
            }
        } else {
            _login()
        }
    }
    
    public class func reconnectCurrent() {
        guard let userLogin = loadLogin().1 else { return }
        CentralisTabBarController.shared.set(title: "Reconnecting", subtitle: "Reconnecting to EduLink", progress: 0)
        login(userLogin) { error, _ in
            if let error = error {
                CentralisTabBarController.shared.set(title: "Error Connecting", subtitle: error, progress: 0.5)
            } else {
                PersistenceDatabase.backgroundRefresh {
                    
                }
            }
        }
    }
}

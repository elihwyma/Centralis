//
//  AlwaysOnlineManager.swift
//  Centralis
//
//  Created by Amy While on 24/09/2022.
//

import UIKit
import Evander

public final class AlwaysOnlineManager {
    
    static let shared = AlwaysOnlineManager()
    
    public var alwaysOnlineEnabled = false
    public var signInWithAppleEnabled = false
    
    public func getNotificationToken(_ completion: @escaping (String?) -> Void) {
        (UIApplication.shared.delegate as! AppDelegate).tokenCallback = completion
        Thread.mainBlock {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    public func checkState(_ completion: @escaping (Bool, Bool, Bool) -> Void) {
        let url = AMY_API.appendingPathComponent("centralis/check")
        guard let cacheUser = EdulinkManager.shared.authenticatedUser else { return completion(false, false, false) }
        let dict = [
            "identifier": "\(cacheUser.login?.schoolID ?? "")-\(cacheUser.learner_id)"
        ]
        EvanderNetworking.request(url: url, type: [String: Any].self, method: "POST", json: dict) { success, status, error, dict in
            guard let dict = dict,
                  let aoe = dict["aoe"] as? Bool,
                  let siwa = dict["siwa"] as? Bool else { return completion(false, false, false) }
            self.alwaysOnlineEnabled = aoe
            self.signInWithAppleEnabled = siwa
            completion(true, aoe, siwa)
        }
    }
    
    public func registerForOnline(_ completion: @escaping (Bool, String?) -> Void) {
        getNotificationToken { token in
            guard let token = token else {
                return completion(false, "Are notifications registered?")
            }
            let url = AMY_API.appendingPathComponent("centralis/add")
            guard let cacheUser = LoginManager.loadLogin().1 else { return completion(false, "No account saved?") }
            let dict = [
                "notificationToken": token,
                "username": cacheUser.username,
                "password": cacheUser.password,
                "schoolCode": cacheUser.schoolCode
            ]
            print("Extra cu")
            EvanderNetworking.request(url: url, type: [String: Any].self, method: "POST", json: dict) { success, status, error, dict in
                guard let dict = dict else { return completion(false, error?.localizedDescription ??  "Unknown Error") }
                if (dict["success"] as? Bool ?? false) {
                    return completion(true, nil)
                }
                return completion(false, dict["error"] as? String ?? "Unknown Error")
            }
        }
    }
    
    public func registerForAppleID(token: String, identity: String) {
        let url = AMY_API.appendingPathComponent("centralis/addapple")
        guard let cacheUser = LoginManager.loadLogin().1 else { return }
        let dict = [
            "username": cacheUser.username,
            "password": cacheUser.password,
            "schoolCode": cacheUser.schoolCode,
            "token": token,
            "identity-token": identity
        ]
        EvanderNetworking.request(url: url, type: [String: Any].self, method: "POST", json: dict) { success, status, error, dict in
            print(dict)
            print(success)
            print(error)
            print(status)
        }
    }
    
    public func signIn(token: String, identity: String, _ completion: @escaping (String?, UserLogin?) -> Void) {
        let url = AMY_API.appendingPathComponent("centralis/applesignin")
        let dict = [
            "token": token,
            "identity-token": identity
        ]
        EvanderNetworking.request(url: url, type: [String: Any].self, method: "POST", json: dict) { success, status, error, dict in
            guard let dict = dict else { return completion("Request Failed :(", nil) }
            if (dict["success"] as? Bool ?? false) {
                print(dict)
                guard let data = dict["data"] as? [String: String],
                      let username = data["username"],
                      let password = data["password"],
                      let schoolCode = data["schoolCode"],
                      let schoolID = data["schoolID"],
                      let serverURL = URL(string: data["serverURL"] ?? "") else { return completion("Something went wrong with CUM :(", nil) }
                let userLogin = UserLogin(server: serverURL, schoolID: schoolID, schoolCode: schoolCode, username: username, password: password)
                return completion(nil, userLogin)
            }
            return completion(dict["error"] as? String ?? "No Account linked with this Apple ID", nil)
        }
    }
    
}

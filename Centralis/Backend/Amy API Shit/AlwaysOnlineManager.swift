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
    
    public func getNotificationToken(_ completion: @escaping (String?) -> Void) {
        (UIApplication.shared.delegate as! AppDelegate).tokenCallback = completion
        Thread.mainBlock {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    public func registerForOnline(_ completion: @escaping (String?) -> Void) {
        print("Cum")
        getNotificationToken { token in
            guard let token = token else {
                return completion("Are notifications registered?")
            }
            let url = AMY_API.appendingPathComponent("centralis/add")
            guard let cacheUser = LoginManager.loadLogin().1 else { return completion("No account saved?") }
            let dict = [
                "notificationToken": token,
                "username": cacheUser.username,
                "password": cacheUser.password,
                "schoolCode": cacheUser.schoolCode
            ]
            print("Extra cu")
            EvanderNetworking.request(url: url, type: [String: Any].self, method: "POST", json: dict) { success, status, error, type in
                print(status)
                print(success)
                print(error)
                print(type)
            }
        }
    }
    
}

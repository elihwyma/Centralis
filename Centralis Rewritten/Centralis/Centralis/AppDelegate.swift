//
//  AppDelegate.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        LoginManager.loadSchool(from: "calday") { error, schoolDetails in
            guard let schoolDetails = schoolDetails else {
                NSLog("[Centralis] \(error)")
                return
            }
            let savedLogin = UserLogin(server: schoolDetails.server, schoolID: schoolDetails.school_id, schoolCode: schoolDetails.code, username: USERNAME, password: PASSWORD)
            LoginManager.login(savedLogin) { error, authenticatedUser in
                
            }
        }
        
        return true
    }

}


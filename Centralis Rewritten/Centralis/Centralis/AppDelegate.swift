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
        let start = DispatchTime.now()
        LoginManager.loadSchool(from: "calday") { error, schoolDetails in
            guard let schoolDetails = schoolDetails else {
                NSLog("[Centralis] \(error)")
                return
            }
            let mid = DispatchTime.now()
            let savedLogin = UserLogin(server: schoolDetails.server, schoolID: schoolDetails.school_id, schoolCode: schoolDetails.code, username: USERNAME, password: PASSWORD)
            LoginManager.login(savedLogin) { error, authenticatedUser in
                NSLog("[Centralis] \(error) \(authenticatedUser)")
                let end = DispatchTime.now()
                
                let resolvingSchool = mid.uptimeNanoseconds - start.uptimeNanoseconds
                let loggingIn = end.uptimeNanoseconds - mid.uptimeNanoseconds
                
                NSLog("[Centralis] Resolving School Took \(Double(resolvingSchool) / 1_000_000_000) seconds")
                NSLog("[Centralis] Logging In To School Took \(Double(loggingIn) / 1_000_000_000) seconds")
            }
        }

        return true
    }

}


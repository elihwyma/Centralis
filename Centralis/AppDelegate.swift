//
//  AppDelegate.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import UIKit
import UserNotifications
import Evander

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        EvanderNetworking._cacheDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.amywhile.centralis")!.appendingPathComponent("Library")
        
        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        
        #if !APPCLIP
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        #endif
        
        return true
    }
    
    #if !APPCLIP
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let login = LoginManager.loadLogin().1 else { return completionHandler(.newData) }
        LoginManager.login(login, _indexBypass: true) { error, user in
            if user != nil {
                PersistenceDatabase.backgroundRefresh {
                    completionHandler(.newData)
                }
            } else {
                return completionHandler(.newData)
            }
        }
    }
    #endif
    
    func setRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard animated, let window = self.window else {
            self.window?.rootViewController = vc
            self.window?.makeKeyAndVisible()
            return
        }

        window.rootViewController = vc
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
    }
}

extension UIApplicationDelegate {
    
    var window: UIWindow? {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    }
        
}


//
//  AppDelegate.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import UIKit
import UserNotifications
import Evander

let currentResetVersion = 0x00000001

// @main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var hasEnteredBackground = false
    
    public var tokenCallback: ((String?) -> Void)?
    
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
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        _ = ThemeManager.shared
        
        if PersistenceDatabase.domainDefaults.integer(forKey: "Version") < currentResetVersion {
            EdulinkManager.shared.signout()
            PersistenceDatabase.domainDefaults.set(currentResetVersion, forKey: "Version")
        }
        
        if let login = LoginManager.loadLogin().1 {
            window?.rootViewController = CentralisTabBarController.shared
            Message.setUnread()
            LoginMiddleware.shared.login(with: login)
        } else {
            window?.rootViewController = CentralisNavigationController(rootViewController: OnboardingViewController())
        }
        window?.makeKeyAndVisible()
        window?.tintColor = .tintColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(themeDidChange), name: ThemeManager.ThemeUpdate, object: nil)
        
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        tokenCallback?(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        tokenCallback?(nil)
    }
    
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
    
    @objc private func themeDidChange() {
        window?.tintColor = .tintColor
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        hasEnteredBackground = true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        guard hasEnteredBackground else { return }
        NotificationCenter.default.post(name: PersistenceDatabase.persistenceReload, object: nil)
        LoginManager.reconnectCurrent()
    }
}


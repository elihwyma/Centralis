//
//  AppDelegate.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import UIKit
import BackgroundTasks
import UserNotifications
import Evander

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        EvanderNetworking._cacheDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.amywhile.centralis")!.appendingPathComponent("Library")
        
        let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
        //try? PersistenceDatabase.shared.resetDatabase()
        _ = PersistenceDatabase.shared.timetable
        //EdulinkManager.shared.signout()
        self.window = UIWindow(frame: UIScreen.main.bounds)

        if let login = LoginManager.loadLogin().1 {
            window?.rootViewController = CentralisTabBarController.shared
            LoginMiddleware.shared.login(with: login)
        } else {
            window?.rootViewController = CentralisNavigationController(rootViewController: OnboardingViewController())
        }
        window?.makeKeyAndVisible()
        Message.setUnread()
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)

        return true
    }
    
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
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: PersistenceDatabase.persistenceReload, object: nil)
        LoginManager.reconnectCurrent()
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
}


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
        
        //EdulinkManager.shared.signout()
        self.window = UIWindow(frame: UIScreen.main.bounds)
        if let login = LoginManager.loadLogin().1 {
            window?.rootViewController = CentralisNavigationController(rootViewController: QuickLoginViewController.viewControllerFor(login: login))
        } else {
            window?.rootViewController = CentralisNavigationController(rootViewController: OnboardingViewController())
        }
        window?.makeKeyAndVisible()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance

        return true
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


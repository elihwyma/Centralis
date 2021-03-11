//
//  AppDelegate.swift
//  Centralis
//
//  Created by Amy While on 28/11/2020.
//

import UIKit
//import libCentralis

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        guard let ps = UserDefaults.standard.value(forKey: "PreferredSchool") as? String, let pu = UserDefaults.standard.value(forKey: "PreferredUsername") as? String else { return true }
        let decoder = JSONDecoder()
        let l = UserDefaults.standard.object(forKey: "LoginCache") as? [Data] ?? [Data]()
        for login in l {
            if let a = try? decoder.decode(SavedLogin.self, from: login) {
                if a.username == pu && a.schoolCode == ps {
                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                    let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                    let navigationController = UINavigationController.init(rootViewController: viewController)
                    viewController.login = a
                    viewController.arriveFromDelegate()
                    navigationController.navigationItem.largeTitleDisplayMode = .always
                    navigationController.navigationBar.prefersLargeTitles = true
                    self.window?.rootViewController = navigationController
                    self.window?.makeKeyAndVisible()
                    return true
                }
            }
        }
        return true
    }
}


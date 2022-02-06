//
//  LoginMiddleware.swift
//  Centralis
//
//  Created by Amy While on 30/01/2022.
//

import UIKit

public final class LoginMiddleware: ReachabilityChange {
    
    static let shared = LoginMiddleware()
    
    init() {
        Reachability.shared.delegate = self
    }
    
    public func login(with login: UserLogin) {
        CentralisTabBarController.shared.set(title: "Logging In", subtitle: "Connecting as \(login.username)", progress: 0)
        LoginManager.login(login) { error, authenticatedUser in
            Thread.mainBlock {
                if let error = error {
                    if error == "The username or password is incorrect. Please try typing your password again" {
                        let viewController = UserPasswordViewController(login: login)
                        viewController.errorLabel.text = error
                        EdulinkManager.shared.signout()
                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = viewController
                    }
                    CentralisTabBarController.shared.set(title: "Failed to Connect", subtitle: error, progress: 0)
                }
            }
        }
    }
    
    public func statusDidChange(connected: Bool) {
        if !connected {
            CentralisTabBarController.shared.set(title: "Poor Connection", subtitle: "No Connection Could be Made", progress: 0)
        } else {
            LoginManager.reconnectCurrent()
        }
    }
    
}

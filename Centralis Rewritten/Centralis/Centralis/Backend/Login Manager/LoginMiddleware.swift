//
//  LoginMiddleware.swift
//  Centralis
//
//  Created by Amy While on 30/01/2022.
//

import UIKit

public final class LoginMiddleware {
    
    static let shared = LoginMiddleware()
    
    public func login(with login: UserLogin) {
        CentralisTabBarController.shared.set(title: "Logging In", subtitle: "Connecting as \(login.username)", progress: 0)
        LoginManager.login(login) { error, authenticatedUser in
            if let error = error {
                if error == "The username or password is incorrect. Please try typing your password again" {
                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = CentralisNavigationController(rootViewController: OnboardingViewController())
                }
                CentralisTabBarController.shared.set(title: "Failed to Connect", subtitle: error, progress: 0)
            }
        }
    }
    
}

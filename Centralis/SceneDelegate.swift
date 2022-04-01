//
//  SceneDelegate.swift
//  Centralis
//
//  Created by Amy While on 06/02/2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var hasEnteredBackground = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        if let login = LoginManager.loadLogin().1 {
            window?.rootViewController = CentralisTabBarController.shared
            Message.setUnread()
            LoginMiddleware.shared.login(with: login)
        } else {
            window?.rootViewController = CentralisNavigationController(rootViewController: OnboardingViewController())
        }
        window?.makeKeyAndVisible()
        window?.tintColor = .tintColor
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        guard hasEnteredBackground else { return }
        NotificationCenter.default.post(name: PersistenceDatabase.persistenceReload, object: nil)
        LoginManager.reconnectCurrent()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        hasEnteredBackground = true
    }


}


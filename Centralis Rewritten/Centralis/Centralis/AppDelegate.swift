//
//  AppDelegate.swift
//  Centralis
//
//  Created by Andromeda on 22/11/2021.
//

import UIKit
import BackgroundTasks
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //try? PersistenceDatabase.shared.resetDatabase()
        _ = PersistenceDatabase.shared.timetable
        //EdulinkManager.shared.signout()
        self.window = UIWindow(frame: UIScreen.main.bounds)

        if let login = LoginManager.loadLogin().1 {
            window?.rootViewController = QuickLoginViewController.viewController(for: login)
        } else {
            window?.rootViewController = CentralisNavigationController(rootViewController: OnboardingViewController())
        }
        window?.makeKeyAndVisible()
    
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.amywhile.centralis.backgroundindex",
                                        using: nil) { (task) in
            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }

        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleBackgroundIndex()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        typealias lM = LoginManager
        guard let login = lM.loadLogin().1 else { return }
        LoginManager.login(login) { error, _ in
            if let error = error {
                NSLog("[Centralis] Error = \(error)")
                #warning("[Centralis] Handle the Error")
            }
        }
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
    
    private func handleAppRefreshTask(task: BGAppRefreshTask) {
        let content = UNMutableNotificationContent()
        content.title = "Background Task"
        content.body = "Background task successfully called!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
        guard let login = LoginManager.loadLogin().1 else { return task.setTaskCompleted(success: false) }
        LoginManager.login(login, _indexBypass: true) { _, user in
            if user != nil {
                PersistenceDatabase.backgroundRefresh {
                    task.setTaskCompleted(success: true)
                }
            } else {
                return task.setTaskCompleted(success: false)
            }
        }
        scheduleBackgroundIndex()
    }
    
    func scheduleBackgroundIndex() {
        let indexTask = BGAppRefreshTaskRequest(identifier: "com.amywhile.centralis.backgroundindex")
        indexTask.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        do {
            try BGTaskScheduler.shared.submit(indexTask)
        } catch {
            print("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
}


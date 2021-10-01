//
//  AppDelegate.swift
//  Centralis
//
//  Created by AW on 28/11/2020.
//

import UIKit
import BackgroundTasks
import UserNotifications
//import libCentralis

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600 * 3)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        if let user = LoginManager.user() {
            self.window?.rootViewController = CentralisNavigationController(rootViewController: BaseViewController(login: user, auth: true))
        } else {
            self.window?.rootViewController = CentralisNavigationController(rootViewController: LoginViewController())
        }
        self.window?.makeKeyAndVisible()
        return true
    }
    
    private func notificationRefresh(completionHandler: @escaping (_ success: Bool) -> Void) {
        guard var notificationPreferences = EduLinkAPI.shared.defaults.dictionary(forKey: "RegisteredNotifications") else {
            return completionHandler(true)
        }
        guard let user = LoginManager.user() else { return completionHandler(false) }
        LoginManager.shared.quickLogin(user, { (success, error) -> Void in
            if !success { return completionHandler(false) }
            EduLink_Timetable.timetable({(success, error) -> Void in
                if !success { return completionHandler(false) }
                if notificationPreferences["RoomChanges"] as? Bool ?? false {
                    let week = EduLinkAPI.shared.weeks.first(where: {$0.is_current}) ?? EduLinkAPI.shared.weeks.first
                    if let day = week?.days.first(where: {$0.isCurrent}) {
                        var postedChanges = notificationPreferences["RoomChangePosted"] as? [String : Any] ?? [String : Any]()
                        var postedID = postedChanges["PostedID"] as? [String] ?? [String]()
                        // Garbage Cleanup
                        if (postedChanges["day"] as? String ?? "") == day.name { postedID.removeAll(); postedChanges["day"] = day.name }
                        for period in day.periods where !postedID.contains(period.id ) {
                            if let lesson = period.lesson {
                                if lesson.moved {
                                    self.sendNotification(title: "Room Change", body: "\(lesson.subject) at \(period.start_time.time) has been moved to \(lesson.room_name ?? "Unknown")")
                                    postedID.append(period.id )
                                }
                            }
                        }
                        postedChanges["PostedID"] = postedID
                        notificationPreferences["RoomChangePosted"] = postedChanges
                    }
                }
                // Check for homework, easiest way to do this is chained completionHandlers, Swift 5.5 wya
                EduLink_Homework.homework({(success, error) -> Void in
                    if !success { return completionHandler(false) }
                    if notificationPreferences["HomeworkChanges"] as? Bool ?? false {
                        var postedChanges = notificationPreferences["HomeworkPosted"] as? [String : Any] ?? [String : Any]()
                        let postedNew = postedChanges["PostedNew"] as? [String] ?? [String]()
                        var newID = [String]()
                        for homework in EduLinkAPI.shared.homework.current {
                            if postedNew.contains(homework.id) { continue }
                            newID.append(homework.id)
                            self.sendNotification(title: "New Homework", body: "\(homework.set_by ?? "") has set \"\(homework.activity ?? "")\" due for \(homework.due_date?.shortDate ?? "")")
                        }
                        postedChanges["PostedNew"] = newID
                        notificationPreferences["HomeworkPosted"] = postedChanges
                    }
                    EduLinkAPI.shared.defaults.setValue(notificationPreferences, forKey: "RegisteredNotifications")
                    completionHandler(true)
                })
            })
        })
    }
    
    private func scheduleAppRefresh() {
        let request = BGProcessingTaskRequest(identifier: "com.amywhile.centralis.backgroundrefresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15)
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(request)
            print(request)
        } catch {
            print("Could not schedule app refresh task \(error.localizedDescription)")
        }
    }
    
    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID.uuid, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Schedule background tasks
        //self.scheduleAppRefresh()
    }
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        self.notificationRefresh(completionHandler: {(success) -> Void in
            //task.setTaskCompleted(success: true)
            //self.scheduleAppRefresh()
            completionHandler(.newData)
        })
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


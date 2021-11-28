//
//  NotificationManager.swift
//  Centralis
//
//  Created by Andromeda on 27/11/2021.
//

import Foundation
import UserNotifications

final public class NotificationManager {
    
    static let shared = NotificationManager()
    let center = UNUserNotificationCenter.current()
    
    private func convertToDayBefore(_ date: Date) -> Date {
        convertToDesired(date.dayBefore)
    }
    
    private func convertToDesired(_ date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.month, .day, .year], from: date)
        components.hour = 17
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
    
    init() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
    }
    
    public func removeAllNotifications() {
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
    }
    
    public func removeNotifications(with identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    public func scheduleHomework(homework: [Homework]) {
        var homework = homework
        homework.removeAll { !$0.isCurrent || $0.notificationState == .notified || $0.completed || $0.notificationState == .past }
        for homework in homework {
            defer {
                homework.notificationState = .notified
            }
            if homework.isDueTomorrow || homework.notificationState == .dayBefore {
                let interval = Date().distance(to: convertToDayBefore(homework.due_date!))
                if interval <= 0 { continue }
                let content = UNMutableNotificationContent()
                content.title = "\(homework.subject) homework due tomorrow"
                content.subtitle = homework.set_by
                content.body = "\(homework.activity)"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                center.add(UNNotificationRequest(identifier: "\(String(describing: homework.id))-Tomorrow",
                                                 content: content,
                                                 trigger: trigger))
                continue
            }
            if let due_date = homework.due_date {
                let content = UNMutableNotificationContent()
                content.title = "New \(homework.subject) homework due in \(due_date.days(sinceDate: Date())) days"
                content.subtitle = homework.set_by
                content.body = "\(homework.activity)"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                center.add(UNNotificationRequest(identifier: "\(String(describing: homework.id))-Future",
                                                 content: content,
                                                 trigger: trigger))
            }
        }
        PersistenceDatabase.HomeworkDatabase.updateNotification(homework: homework)
    }
    
    public func deleteHomework(_ homework: Homework) {
        center.removePendingNotificationRequests(withIdentifiers: ["\(homework.id!)-Future", "\(homework.id!)-Tomorrow"])
        center.removeDeliveredNotifications(withIdentifiers: ["\(homework.id!)-Future", "\(homework.id!)-Tomorrow"])
    }
    
    public func homeworkChangeCompleted(homework: Homework) {
        if homework.completed {
            deleteHomework(homework)
        } else {
            scheduleHomework(homework: [homework])
        }
    }
    
    public func homeworkChangeDate(homework: Homework) {
        deleteHomework(homework)
        scheduleHomework(homework: [homework])
    }
}

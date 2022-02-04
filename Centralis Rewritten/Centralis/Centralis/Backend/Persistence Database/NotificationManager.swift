//
//  NotificationManager.swift
//  Centralis
//
//  Created by Andromeda on 27/11/2021.
//

import Foundation
import UserNotifications
import Evander

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
    
    private func convertToEarly(_ date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.month, .day, .year], from: date)
        components.hour = 8
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
    
    public func scheduleHomework(homework: [Homework], _ bypass: Bool = false) {
        guard UserDefaults.standard.optionalBool("Notifications.Homework", fallback: true) else { return }
        var homework = homework
        if !bypass {
            homework.removeAll { !$0.isCurrent || $0.notificationState == .notified || $0.completed || $0.notificationState == .past }
        }
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
                center.add(UNNotificationRequest(identifier: "\(String(describing: homework.id))-Tomorrow-$Homework",
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
                center.add(UNNotificationRequest(identifier: "\(String(describing: homework.id))-Future-$Homework",
                                                 content: content,
                                                 trigger: trigger))
            }
        }
        PersistenceDatabase.HomeworkDatabase.updateNotification(homework: homework)
    }
    
    public func deleteHomework(_ homework: Homework) {
        center.removePendingNotificationRequests(withIdentifiers: ["\(homework.id!)-Future-$Homework", "\(homework.id!)-Tomorrow-$Homework"])
        center.removeDeliveredNotifications(withIdentifiers: ["\(homework.id!)-Future-$Homework", "\(homework.id!)-Tomorrow-$Homework"])
    }
    
    public func deleteAllHomework() {
        center.getPendingNotificationRequests { requests in
            var requests = requests
            requests = requests.filter { $0.identifier.contains("$Homework") }
            self.center.removePendingNotificationRequests(withIdentifiers: requests.map { $0.identifier })
        }
    }
    
    public func scheduleAllHomework() {
        let homework = PersistenceDatabase.shared.homework.map { $0.1 }.filter { $0.isCurrent }
        scheduleHomework(homework: homework, true)
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
    
    public func scheduleRoomChange(date: Date, period: Timetable.Period) {
        guard UserDefaults.standard.optionalBool("Notifications.RoomChange", fallback: true),
              let room = period.room,
              let teacher = period.teachers,
              let subject = period.subject else { return }
        let converted = convertToEarly(date)
        let content = UNMutableNotificationContent()
        content.title = "Room Change for \(subject)"
        content.subtitle = subject
        content.body = "You're in \(room) for \(subject) today with \(teacher)"
        var interval = Date().distance(to: converted)
        if interval <= 0 {
            interval = 1
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        center.add(UNNotificationRequest(identifier: "\(period.id)-Future-$RoomChange",
                                         content: content,
                                         trigger: trigger))
    }
    
    public func deleteAllRoomChange() {
        center.getPendingNotificationRequests { requests in
            var requests = requests
            requests = requests.filter { $0.identifier.contains("$RoomChange") }
            self.center.removePendingNotificationRequests(withIdentifiers: requests.map { $0.identifier })
        }
    }
    
    public func notifyMessage(message: Message) {
        guard UserDefaults.standard.optionalBool("Notifications.NewMessages", fallback: true) else { return }
        let content = UNMutableNotificationContent()
        content.title = "New Message from \(message.sender.name)"
        content.subtitle = message.subject ?? ""
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        center.add(UNNotificationRequest(identifier: "\(message.id ?? "-1")-Message-$NewMessage", content: content, trigger: trigger))
    }
}

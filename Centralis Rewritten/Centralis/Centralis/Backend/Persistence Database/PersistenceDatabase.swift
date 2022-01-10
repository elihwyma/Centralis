//
//  PersistenceDatabase.swift
//  Centralis
//
//  Created by Andromeda on 27/11/2021.
//

import Foundation
import SQLite
import Evander
import SQLite3

enum DatabaseSchemaVersion: Int32 {
    case versionNil = 0
    case version01000 = 1
    case version01001 = 2
}

final public class PersistenceDatabase {
    
    static private (set) public var shared = PersistenceDatabase()
    private var database: Connection
    private let databaseFolder = EvanderNetworking._cacheDirectory.appendingPathComponent("Database")
    
    private(set) public lazy var homework: [String: Homework] = HomeworkDatabase.getHomework(database: database)
    private(set) public lazy var timetable: [Timetable.Week] = TimetableDatabase.getTimetable(database: database)
    private(set) public lazy var messages: [String: Message] = [:]
    
    static let persistenceReload = Notification.Name(rawValue: "Centralis/PersistenceReload")
    
    private init() {
        _ = NotificationManager.shared
        if !databaseFolder.dirExists {
            try? FileManager.default.createDirectory(at: databaseFolder, withIntermediateDirectories: true)
        }
        let databaseURL = databaseFolder.appendingPathComponent("CentralisPersistence.sqlite3")
        NSLog("URL = \(databaseURL)")
        guard let database = try? Connection(databaseURL.path) else {
            fatalError("Database Connection failed")
        }
        self.database = database
        self.schemaVersion = DatabaseSchemaVersion.version01001.rawValue
        
        HomeworkDatabase.createTable(database: database)
        TimetableDatabase.createTable(database: database)
    }
    
    private var schemaVersion: Int32 {
        // swiftlint:disable:next force_cast force_try
        get { Int32(try! database.scalar("PRAGMA user_version") as! Int64) }
        // swiftlint:disable:next force_try
        set { try! database.run("PRAGMA user_version = \(newValue)") }
    }
    
    public var hasIndexed: Bool {
        get { databaseFolder.appendingPathComponent(".INDEXED").exists }
        set(indexed) {
            if indexed {
                try? Data().write(to: databaseFolder.appendingPathComponent(".INDEXED"))
            } else {
                try? FileManager.default.removeItem(at: databaseFolder.appendingPathComponent(".INDEXED"))
            }
        }
    }
    
    public class func persistenceIndex(_ completion: @escaping (String?, Bool) -> Void) {
        try? PersistenceDatabase.shared.resetDatabase()
        let `self` = PersistenceDatabase.shared
        let loadGroup = DispatchGroup()
        loadGroup.enter()
        loadGroup.enter()
        Homework.updateHomework(indexing: true) { [weak self] error, homework in
            guard let homework = homework,
                  let database = self?.database else {
                return completion(error ?? "Unknown Error", false)
            }
            HomeworkDatabase.saveHomework(homework: homework, notificationState: .dayBefore, database: database)
            var tmp = [String: Homework]()
            homework.forEach { tmp[$0.id] = $0 }
            self?.homework = tmp
            loadGroup.leave()
        }
        Timetable.updateTimetable(indexing: true) { [weak self] error, weeks in
            guard let weeks = weeks,
                  let database = self?.database else {
                      return completion(error ?? "Unknown Error", false)
            }
            TimetableDatabase.saveTimetable(weeks: weeks, database: database)
            loadGroup.leave()
        }
        loadGroup.notify(queue: .main) { [weak self] in
            self?.hasIndexed = true
            completion(nil, true)
        }
    }
    
    public class func backgroundRefresh(_ completion: @escaping () -> Void) {
        let loadGroup = DispatchGroup()
        loadGroup.enter()
        loadGroup.enter()
        loadGroup.enter()
        Homework.updateHomework { _, _ in
            loadGroup.leave()
        }
        Timetable.updateTimetable { _, _ in
            Self.shared.timetable = TimetableDatabase.getTimetable(database: Self.shared.database)
            loadGroup.leave()
        }
        Message.updateMessages { _, _ in
            loadGroup.leave()
        }
        loadGroup.notify(queue: .global(qos: .background)) {
            NotificationCenter.default.post(name: persistenceReload, object: nil)
            completion()
        }
    }
    
    public func resetDatabase() throws {
        sqlite3_close(database.handle)
        try FileManager.default.removeItem(at: databaseFolder.appendingPathComponent("CentralisPersistence.sqlite3"))
        hasIndexed = false
        Self.shared = PersistenceDatabase()
    }
    
    struct HomeworkDatabase {
        static let id = Expression<String>("id")
        static let available_date = Expression<Date?>("available_date")
        static let due_date = Expression<Date?>("due_date")
        static let completed = Expression<Bool>("completed")
        static let description = Expression<String?>("description")
        static let activity = Expression<String>("activity")
        static let source = Expression<String>("source")
        static let set_by = Expression<String>("set_by")
        static let subject = Expression<String>("subject")
        static let notified = Expression<Int64>("notified")
        static let homeworkTable = Table("Homework")
        
        static func createTable(database: Connection) {
            _ = try? database.run(homeworkTable.create(ifNotExists: true,
                                                       block: { tbd in
                tbd.column(id, primaryKey: true)
                tbd.column(available_date)
                tbd.column(due_date)
                tbd.column(completed)
                tbd.column(description)
                tbd.column(activity)
                tbd.column(source)
                tbd.column(set_by)
                tbd.column(subject)
                tbd.column(notified)
            }))
        }
        
        static func saveHomework(homework: [Homework], notificationState: Homework.NotificationState?, database: Connection) {
            try? database.transaction {
                for homework in homework {
                    let state = notificationState ?? homework.notificationState
                    homework.notificationState = state
                    let count = try? database.scalar(homeworkTable.filter(id == homework.id).count)
                    if count ?? 0 > 0 { continue }
                    _ = try? database.run(homeworkTable.insert(
                        id <- homework.id,
                        available_date <- homework.available_date,
                        due_date <- homework.due_date,
                        completed <- homework.completed,
                        description <- homework.description,
                        activity <- homework.activity,
                        source <- homework.source,
                        set_by <- homework.set_by,
                        subject <- homework.subject,
                        notified <- homework.notificationState.rawValue
                    ))
                }
            }
            NotificationManager.shared.scheduleHomework(homework: homework)
        }
        
        static func getHomework(database: Connection) -> [String: Homework] {
            var homeworks = [String: Homework]()
            let query = homeworkTable.select(id,
                                             available_date,
                                             due_date,
                                             completed,
                                             description,
                                             activity,
                                             source,
                                             set_by,
                                             subject,
                                             notified)
            do {
                for stub in try database.prepare(query) {
                    let homework = Homework(available_date: stub[available_date],
                                            completed: stub[completed],
                                            due_date: stub[due_date],
                                            description: stub[description],
                                            activity: stub[activity],
                                            source: stub[source],
                                            set_by: stub[set_by],
                                            subject: stub[subject],
                                            id: stub[id])
                    homework.notificationState = .init(rawValue: stub[notified])!
                    homeworks[homework.id] = homework
                }
            } catch {}
            return homeworks
        }
        
        static func changes(newHomework: inout [Homework]) {
            let persistence = PersistenceDatabase.shared
            let current = persistence.homework
            try? persistence.database.transaction {
                for (_, current) in current where current.notificationState != .past && !current.isCurrent {
                    let homework = homeworkTable.filter(id == current.id)
                    _ = try? persistence.database.run(homework.update(notified <- Homework.NotificationState.past.rawValue))
                }
                for new in newHomework where new != current[new.id] {
                    let homework = homeworkTable.filter(id == new.id)
                    _ = try? persistence.database.run(homework.update(
                        due_date <- new.due_date,
                        activity <- new.activity
                    ))
                    let current = current[new.id]
                    current?.due_date = new.due_date
                    current?.activity = new.activity
                    NotificationManager.shared.homeworkChangeDate(homework: new)
                }
                for new in newHomework where new.completed != current[new.id]?.completed {
                    let homework = homeworkTable.filter(id == new.id)
                    _ = try? persistence.database.run(homework.update(
                        completed <- new.completed
                    ))
                    let current = current[new.id]
                    current?.completed = new.completed
                    NotificationManager.shared.homeworkChangeCompleted(homework: new)
                }
            }
            newHomework.removeAll { current[$0.id] != nil }
            newHomework.forEach { persistence.homework[$0.id] = $0 }
            saveHomework(homework: newHomework, notificationState: nil, database: persistence.database)
        }
        
        static func updateDescription(homework: Homework) {
            let tableHomework = homeworkTable.filter(id == homework.id)
            _ = try? PersistenceDatabase.shared.database.run(tableHomework.update(description <- homework.description))
        }
        
        static func updateCompleted(homework: Homework) {
            let tableHomework = homeworkTable.filter(id == homework.id)
            _ = try? PersistenceDatabase.shared.database.run(tableHomework.update(completed <- homework.completed))
            NotificationManager.shared.homeworkChangeCompleted(homework: homework)
        }
        
        static func updateNotification(homework: [Homework]) {
            try? PersistenceDatabase.shared.database.transaction {
                for homework in homework {
                    let tableHomework = homeworkTable.filter(id == homework.id)
                    _ = try? PersistenceDatabase.shared.database.run(tableHomework.update(notified <- homework.notificationState.rawValue))
                }
            }
        }
    }
    
    struct TimetableDatabase {
        
        static let weekTable = Table("Week")
        static let dayTable = Table("Day")
        static let periodTable = Table("Period")
        
        static let id_key = Expression<Int64>("id_key")
        static let parent_key = Expression<Int64>("parent_key")
        static let name = Expression<String>("name")
        static let date = Expression<Date>("date")
        
        static let empty = Expression<Bool>("empty")
        static let end_time = Expression<String>("end_time")
        static let start_time = Expression<String>("start_time")
        static let id = Expression<String>("id")
        static let moved = Expression<Bool>("moved")
        static let subject = Expression<String?>("subject")
        static let room = Expression<String?>("room")
        static let teachers = Expression<String?>("teachers")
        
        static func createTable(database: Connection){
            _ = try? database.run(weekTable.create(ifNotExists: true,
                                                       block: { tbd in
                tbd.column(id_key, primaryKey: .autoincrement)
                tbd.column(name)
            }))
            _ = try? database.run(dayTable.create(ifNotExists: true,
                                                       block: { tbd in
                tbd.column(id_key, primaryKey: .autoincrement)
                tbd.column(parent_key)
                tbd.column(name)
                tbd.column(date)
            }))
            _ = try? database.run(periodTable.create(ifNotExists: true,
                                                       block: { tbd in
                tbd.column(parent_key)
                tbd.column(empty)
                tbd.column(end_time)
                tbd.column(start_time)
                tbd.column(id)
                tbd.column(moved)
                tbd.column(subject)
                tbd.column(room)
                tbd.column(teachers)
                tbd.column(name)
            }))
        }
        
        static func saveTimetable(weeks: [Timetable.Week], database: Connection) {
            try? database.transaction {
                for week in weeks {
                    guard let weekID = try? database.run(weekTable.insert(
                        name <- week.name
                    )) else { continue }
                    for day in week.days {
                        guard let dayID = try? database.run(dayTable.insert(
                            parent_key <- weekID,
                            name <- day.name,
                            date <- day.date
                        )) else { continue }
                        for period in day.periods {
                            _ = try? database.run(periodTable.insert(
                                parent_key <- dayID,
                                empty <- period.empty,
                                end_time <- period.end_time,
                                start_time <- period.start_time,
                                id <- period.id,
                                moved <- period.moved,
                                subject <- period.subject,
                                room <- period.room,
                                teachers <- period.teachers,
                                name <- period.name
                            ))
                            if period.moved {
                                NotificationManager.shared.scheduleRoomChange(date: day.date, period: period)
                            }
                        }
                    }
                }
            }
        }
        
        static func getTimetable(database: Connection) -> [Timetable.Week] {
            var weeks = [Timetable.Week]()
            let query = weekTable.select(
                id_key,
                name
            )
            do {
                for weekStub in try database.prepare(query) {
                    let week = Timetable.Week(name: weekStub[name], days: [])
                    let query = dayTable.select(
                        id_key,
                        parent_key,
                        name,
                        date
                    ).filter(parent_key == weekStub[id_key])
                    
                    for dayStub in try database.prepare(query) {
                        let day = Timetable.Day(name: dayStub[name], date: dayStub[date], periods: [])
                        let query = periodTable.select(
                            parent_key,
                            empty,
                            end_time,
                            start_time,
                            id,
                            moved,
                            subject,
                            room,
                            teachers,
                            name
                        ).filter(parent_key == dayStub[id_key])
                
                        let periods: [Timetable.Period] = try database.prepare(query).map { try $0.decode() }
                        day.periods = periods
                        week.days.append(day)
                    }
                    weeks.append(week)
                }
            } catch {}
            return weeks
        }
        
        static func changes(newWeeks: inout [Timetable.Week]) {
            let persistence = PersistenceDatabase.shared
            let database = persistence.database
            let current = persistence.timetable
            try? database.transaction {
                newWeeks = newWeeks.filter { !current.contains($0) }
                let previousDates = Array(current.map { $0.days.map { $0.date } }.joined())
                for week in newWeeks {
                    if let first = week.days.first {
                        let previous = previousDates.contains(first.date)
                        // The database already contains this week but some details may not be the same
                        if previous {
                            let previousWeek: Timetable.Week = {
                                for current in current {
                                    let dates = current.days.map { $0.date }
                                    if dates.contains(first.date) {
                                        return current
                                    }
                                }
                                fatalError()
                            }()
                            let weekIDQuery = dayTable.select(
                                parent_key,
                                date,
                                id
                            ).filter(date == (previousWeek.days.first?.date ?? first.date))
                            var id: Int64? = nil
                            for stub in try database.prepare(weekIDQuery) {
                                id = stub[parent_key]
                                break
                            }
                            for day in previousWeek.days {
                                let dayID = dayTable.select(
                                    id_key,
                                    date
                                ).filter(date == day.date)
                                for stub in try database.prepare(dayID) {
                                    let periodQuery = periodTable.filter(parent_key == stub[id_key])
                                    _ = try? database.run(periodQuery.delete())
                                    let dayQuery = dayTable.filter(date == day.date)
                                    _ = try? database.run(dayQuery.delete())
                                }
                            }
                            if let id = id {
                                let weekQuery = weekTable.filter(id == id_key)
                                _ = try? database.run(weekQuery.delete())
                            }
                        }
                    }
                }
            }
            saveTimetable(weeks: newWeeks, database: database)
        }
    }
    
    struct MessageDatabase {
        
        static let messageTable = Table("Messages")
        static let senderTable = Table("MessageSenders")
        static let attachmentTable = Table("MessageAttachments")
        
        static let date = Expression<Date?>("date")
        static let read = Expression<Date?>("read")
        static let type = Expression<String>("type")
        static let subject = Expression<String?>("subject")
        static let body = Expression<String?>("body")
        static let sender = Expression<String>("sender")
        
        static let filename = Expression<String>("filename")
        static let filesize = Expression<Int64>("filesize")
        static let mime_type = Expression<String>("mime_type")
        static let parent = Expression<String>("parent")
        
        static let name = Expression<String>("name")
        static let id = Expression<String>("id")
        
        static func createTable(database: Connection){
            _ = try? database.run(messageTable.create(ifNotExists: true,
                                                      block: { tbd in
                tbd.column(date)
                tbd.column(read)
                tbd.column(type)
                tbd.column(subject)
                tbd.column(body)
                tbd.column(sender)
            }))
            _ = try? database.run(attachmentTable.create(ifNotExists: true,
                                                         block: { tbd in
                tbd.column(filename)
                tbd.column(filesize)
                tbd.column(mime_type)
                tbd.column(parent)
            }))
            _ = try? database.run(senderTable.create(ifNotExists: true,
                                                     block: { tbd in
                tbd.column(type)
                tbd.column(name)
                tbd.column(id)
            }))
        }
        
        static func saveMessages(_ messages: [String: Message]) {
            let database = PersistenceDatabase.shared.database
            try? database.transaction {
                for message in Array(messages.values) {
                    _ = try? database.run(messageTable.insert(
                        date <- message.date,
                        read <- message.date,
                        type <- message.type,
                        subject <- message.subject,
                        body <- message.body,
                        sender <- message.sender.id
                    ))
                    let count = try? database.scalar(senderTable.filter(id == message.sender.id).count)
                    if count == 0 {
                        _ = try? database.run(senderTable.insert(
                            type <- message.sender.type,
                            name <- message.sender.name,
                            id <- message.sender.id
                        ))
                    }
                    for attachment in message.attachments {
                        _ = try? database.run(attachmentTable.insert(
                            filename <- attachment.filename,
                            filesize <- Int64(attachment.filesize),
                            mime_type <- attachment.mime_type,
                            parent <- message.id
                        ))
                    }
                }
            }
        }
        
        static func getMessages(database: Connection) -> [String: Message] {
            var senders = [String: Sender]()
            let senderQuery = senderTable.select(
                type,
                name,
                id
            )
            do {
                for sender in try database.prepare(senderQuery) {
                    let sender = Sender(id: sender[id],
                                        type: sender[type],
                                        name: sender[name])
                    senders[sender.id] = sender
                }
            } catch {}
            
            var attachments = [String: Attachment]()
            let attachmentQuery = attachmentTable.select(
                filename,
                filesize,
                mime_type,
                id,
                parent
            )
            do {
                for attachment in try database.prepare(attachmentQuery) {
                    let _attachment = Attachment(id: attachment[id],
                                                filename: attachment[filename],
                                                 filesize: Int(attachment[filesize]),
                                                mime_type: attachment[mime_type])
                    attachments[attachment[parent]] = _attachment
                }
            } catch {}
        }
    }
}

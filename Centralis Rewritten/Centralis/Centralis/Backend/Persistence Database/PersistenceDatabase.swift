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
}

final public class PersistenceDatabase {
    
    static private (set) public var shared = PersistenceDatabase()
    private let database: Connection
    private let databaseFolder = EvanderNetworking._cacheDirectory.appendingPathComponent("Database")
    
    private(set) public lazy var homework: [String: Homework] = HomeworkDatabase.getHomework(database: database)
    
    private init() {
        _ = NotificationManager.shared
        if !databaseFolder.dirExists {
            try? FileManager.default.createDirectory(at: databaseFolder, withIntermediateDirectories: true)
        }
        let databaseURL = databaseFolder.appendingPathComponent("CentralisPersistence.sqlite3")
        guard let database = try? Connection(databaseURL.path) else {
            fatalError("Database Connection failed")
        }
        self.database = database
        self.schemaVersion = DatabaseSchemaVersion.version01000.rawValue
        
        HomeworkDatabase.createTable(database: database)
        if hasIndexed {
            self.homework = HomeworkDatabase.getHomework(database: database)
        }
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
        Homework.updatedHomework(indexing: true) { [weak self] error, homework in
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
        loadGroup.notify(queue: .main) { [weak self] in
            self?.hasIndexed = true
            completion(nil, true)
        }
    }
    
    public class func backgroundRefresh(_ completion: @escaping () -> Void) {
        let loadGroup = DispatchGroup()
        loadGroup.enter()
        Homework.updatedHomework { _, _ in
            loadGroup.leave()
        }
        loadGroup.notify(queue: .global(qos: .background)) {
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
        static let available_date = Expression<Int64?>("available_date")
        static let due_date = Expression<Int64?>("due_date")
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
                        available_date <- homework.available_date?.timeIntervalSince1970.int64,
                        due_date <- homework.due_date?.timeIntervalSince1970.int64,
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
                    let homework = Homework(available_date: Date(timeSince1970: stub[available_date]),
                                            completed: stub[completed],
                                            due_date: Date(timeSince1970: stub[due_date]),
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
                        due_date <- new.due_date?.timeIntervalSince1970.int64,
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
}


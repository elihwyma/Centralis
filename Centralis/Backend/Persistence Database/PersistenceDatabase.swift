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

enum DatabaseSchemaVersion: String {
    case version01000 = "1.0"
    case version01001 = "1.0k"
    case version01002 = "1.0ke"
    case version01003 = "1.0ke5"
    case version01004 = "1.0ke7"
}

final public class PersistenceDatabase {
    
    static private (set) public var shared = PersistenceDatabase()
    static public let domainDefaults = UserDefaults(suiteName: "group.amywhile.centralis")!
    private var database: Connection
    private let databaseFolder = EvanderNetworking._cacheDirectory.appendingPathComponent("Database")
    
    private(set) public lazy var homework: [String: Homework] = HomeworkDatabase.getHomework(database: database)
    private(set) public lazy var timetable: [Timetable.Week] = TimetableDatabase.getTimetable(database: database)
    private(set) public lazy var messages: [String: Message] = MessageDatabase.getMessages(database: database)
    private(set) public lazy var documents: [String: Document] = DocumentDatabase.getDocuments(database: database)
    private(set) public lazy var links: [String: Link] = LinkDatabase.getLinks(database: database)
    private(set) public lazy var catering: Catering = CateringDatabase.getCatering(database: database)
    private(set) public lazy var attendance: Attendance = AttendanceDatabase.getAttendance(database: database)
    
    static let persistenceReload = Notification.Name(rawValue: "Centralis/PersistenceReload")
    
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
        if !hasIndexed {
            homework = [:]
            timetable = []
            messages = [:]
            documents = [:]
            links = [:]
            attendance = Attendance()
        }
        
        HomeworkDatabase.createTable(database: database)
        TimetableDatabase.createTable(database: database)
        MessageDatabase.createTable(database: database)
        LinkDatabase.createTable(database: database)
        DocumentDatabase.createTable(database: database)
        CateringDatabase.createTable(database: database)
        AttendanceDatabase.createTable(database: database)
    }

    public var hasIndexed: Bool {
        get {
            let manifest = databaseFolder.appendingPathComponent(".INDEXED")
            if manifest.exists,
                let text = try? String(contentsOf: manifest),
               text == DatabaseSchemaVersion.version01003.rawValue {
                return true
            }
            return false
        }
        set(indexed) {
            if indexed {
                try? DatabaseSchemaVersion.version01003.rawValue.write(to: databaseFolder.appendingPathComponent(".INDEXED"), atomically: false, encoding: .utf8)
            } else {
                try? FileManager.default.removeItem(at: databaseFolder.appendingPathComponent(".INDEXED"))
            }
        }
    }
    
    public class func persistenceIndex(_ completion: @escaping (String?, Bool) -> Void) {
        try? PersistenceDatabase.shared.resetDatabase()
        let `self` = PersistenceDatabase.shared
        let loadGroup = DispatchGroup()
        
        let numberOfTasks = 7
        for _ in 1...numberOfTasks {
            loadGroup.enter()
        }
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
            Self.shared.timetable = TimetableDatabase.getTimetable(database: Self.shared.database)
            loadGroup.leave()
        }
        Message.updateMessages(indexing: true) { error, messages in
            guard messages != nil else {
                return completion(error ?? "Unknown Error", false)
            }
            loadGroup.leave()
        }
        Document.updateDocuments { error, documents in
            guard documents != nil else {
                return completion(error ?? "Unknown Error", false)
            }
            loadGroup.leave()
        }
        Link.updateLinks { error, links in
            guard links != nil else {
                return completion(error ?? "Unknown Error", false)
            }
            loadGroup.leave()
        }
        Catering.updateCatering { error, catering in
            guard catering != nil else {
                return completion(error ?? "Unknown Error", false)
            }
            loadGroup.leave()
        }
        Attendance.updateAttendance { error, attendance in
            guard attendance != nil else {
                return completion(error ?? "Unknown Error", false)
            }
            loadGroup.leave()
        }
        loadGroup.notify(queue: .main) { [weak self] in
            self?.hasIndexed = true
            CentralisTabBarController.shared.setExpanded(false)
            completion(nil, true)
        }
    }
    
    public class func backgroundRefresh(_ completion: @escaping () -> Void) {
        CentralisTabBarController.shared.set(title: "Refreshing Data", subtitle: "This may take a moment", progress: 0.5)
        var currentProgress = CentralisTabBarController.shared.currentProgress
        
        let loadGroup = DispatchGroup()
        
        let numberOfTasks = 7
        for _ in 1...numberOfTasks {
            loadGroup.enter()
        }
        let perGroup = (1.0 - currentProgress) / Float(numberOfTasks)
        func completeTask(with error: String?) {
            if let error = error {
                CentralisTabBarController.shared.set(title: "Error When Refreshing", subtitle: error, progress: currentProgress)
            } else {
                currentProgress += perGroup
                CentralisTabBarController.shared.currentProgress = currentProgress
            }
            loadGroup.leave()
        }
        Homework.updateHomework { error, _ in
            completeTask(with: error)
        }
        Timetable.updateTimetable { error, _ in
            Self.shared.timetable = TimetableDatabase.getTimetable(database: Self.shared.database)
            completeTask(with: error)
        }
        Message.updateMessages { error, _ in
            completeTask(with: error)
        }
        Document.updateDocuments { error, _ in
            completeTask(with: error)
        }
        Link.updateLinks { error, _ in
            completeTask(with: error)
        }
        Catering.updateCatering { error, _ in
            completeTask(with: error)
        }
        Attendance.updateAttendance { error, _ in
            completeTask(with: error)
        }
        loadGroup.notify(queue: .global(qos: .background)) {
            NotificationCenter.default.post(name: persistenceReload, object: nil)
            CentralisTabBarController.shared.setExpanded(false)
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
                // Set the notification state of all past homework to past
                for (_, current) in current where current.notificationState != .past && !current.isCurrent {
                    let homework = homeworkTable.filter(id == current.id)
                    _ = try? persistence.database.run(homework.update(notified <- Homework.NotificationState.past.rawValue))
                }
                
                // Update info about homework that has been edited
                for new in newHomework where current[new.id] != nil && current[new.id]! != new {
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
                
                // Update the completed status of any homework marked completed elsewhere
                for new in newHomework where current[new.id] != nil && new.completed != current[new.id]!.completed {
                    let homework = homeworkTable.filter(id == new.id)
                    _ = try? persistence.database.run(homework.update(
                        completed <- new.completed
                    ))
                    let current = current[new.id]
                    current?.completed = new.completed
                    NotificationManager.shared.homeworkChangeCompleted(homework: new)
                }
            }
            
            // Remove any pre-existing homework
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
        static let group = Expression<String?>("group")
        
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
                tbd.column(group)
            }))
        }
        
        static func saveTimetable(weeks: [Timetable.Week], database: Connection) {
            try? database.transaction {
                for week in weeks {
                    if week.days.isEmpty { continue }
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
                                name <- period.name,
                                group <- period.group
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
                            name,
                            group
                        ).filter(parent_key == dayStub[id_key])
                
                        let periods: [Timetable.Period] = try database.prepare(query).map { try $0.decode() }
                        day.periods = periods
                        week.days.append(day)
                    }
                    weeks.append(week)
                }
            } catch {}
            Timetable.orderWeeks(&weeks)
            weeks.removeAll { $0.days.isEmpty }
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
        static let archived = Expression<Bool>("archived")
        
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
                tbd.column(archived)
                tbd.column(id, unique: true)
            }))
            _ = try? database.run(attachmentTable.create(ifNotExists: true,
                                                         block: { tbd in
                tbd.column(filename)
                tbd.column(filesize)
                tbd.column(mime_type)
                tbd.column(id, unique: true)
                tbd.column(parent)
            }))
            _ = try? database.run(senderTable.create(ifNotExists: true,
                                                     block: { tbd in
                tbd.column(type)
                tbd.column(name)
                tbd.column(id, unique: true)
            }))
        }
        
        static func saveMessages(_ messages: [String: Message]) {
            let database = PersistenceDatabase.shared.database
            try? database.transaction {
                for message in Array(messages.values) {
                    _ = try? database.run(messageTable.insert(
                        date <- message.date,
                        read <- message.read,
                        type <- message.type,
                        subject <- message.subject,
                        body <- message.body,
                        sender <- message.sender.id,
                        id <- message.id,
                        archived <- message.archived
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
                            parent <- message.id,
                            id <- attachment.id
                        ))
                    }
                }
            }
            for (key, value) in Array(messages) {
                PersistenceDatabase.shared.messages[key] = value
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
            
            var attachments = [String: [Attachment]]()
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
                    if let array = attachments[attachment[parent]] {
                        attachments[attachment[parent]] = array + [_attachment]
                    } else {
                        attachments[attachment[parent]] = [_attachment]
                    }
                }
            } catch {}
            
            var messages = [String: Message]()
            let messageQuery = messageTable.select(
                date,
                read,
                type,
                subject,
                body,
                sender,
                id,
                archived
            )
            do {
                for message in try database.prepare(messageQuery) {
                    let id = message[id]
                    let attachments = attachments[id] ?? []
                    guard let sender = senders[message[sender]] else { continue }
                    let _message = Message(id: id,
                                           date: message[date],
                                           read: message[read],
                                           type: message[type],
                                           subject: message[subject],
                                           body: message[body],
                                           archived: message[archived],
                                           attachments: attachments,
                                           sender: sender)
                    messages[_message.id] = _message
                 }
            } catch {}
            
            return messages
        }
        
        static func updateReadStatus(message: Message) {
            let messageFilter = messageTable.filter(id == message.id)
            _ = try? PersistenceDatabase.shared.database.run(messageFilter.update(read <- message.read))
        }
    }
    
    struct DocumentDatabase {
        static let id = Expression<String>("id")
        static let last_updated = Expression<Date?>("last_updated")
        static let filename = Expression<String>("filename")
        static let summary = Expression<String>("summary")
        static let type = Expression<String>("type")
        static let documentTable = Table("Documents")
        
        static func createTable(database: Connection) {
            _ = try? database.run(documentTable.create(ifNotExists: true,
                                                       block: { tbd in
                tbd.column(id, primaryKey: true)
                tbd.column(last_updated)
                tbd.column(filename)
                tbd.column(summary)
                tbd.column(type)
            }))
        }
        
        static func getDocuments(database: Connection) -> [String: Document] {
            var documents = [String: Document]()
            let query = documentTable.select(
                id,
                last_updated,
                filename,
                summary,
                type
            )
            do {
                let _documents: [Document] = try database.prepare(query).map { try $0.decode() }
                _documents.forEach { documents[$0.id] = $0 }
            } catch {}
            return documents
        }

        static func changes(documents: [Document]) {
            let persistence = PersistenceDatabase.shared
            let database = persistence.database
            var current = persistence.documents
            try? database.transaction {
                for document in documents {
                    if let old = current[document.id] {
                        if old == document { continue }
                        _ = try? database.run(documentTable.filter(id == document.id).update(document))
                        current[document.id] = document
                        continue
                    }
                    _ = try? database.run(documentTable.insert(document))
                    current[document.id] = document
                }
            }
            persistence.documents = current
        }
    }
    
    struct LinkDatabase {
        static let id = Expression<String>("id")
        static let name = Expression<String>("name")
        static let url = Expression<URL>("url")
        static let position = Expression<Int>("position")
        static let linkTable = Table("Links")
        
        static func createTable(database: Connection) {
            _ = try? database.run(linkTable.create(ifNotExists: true,
                                                       block: { tbd in
                tbd.column(id, primaryKey: true)
                tbd.column(name)
                tbd.column(url)
                tbd.column(position)
            }))
        }
        
        static func getLinks(database: Connection) -> [String: Link] {
            var links = [String: Link]()
            let query = linkTable.select(
                id,
                name,
                url,
                position
            )
            do {
                let _links: [Link] = try database.prepare(query).map { try $0.decode() }
                _links.forEach { links[$0.id] = $0 }
            } catch {}
            return links
        }

        static func changes(links: [Link]) {
            let persistence = PersistenceDatabase.shared
            let database = persistence.database
            var current = persistence.links
            try? database.transaction {
                for link in links {
                    if let old = current[link.id] {
                        if old == link { continue }
                        _ = try? database.run(linkTable.filter(id == link.id).update(link))
                        current[link.id] = link
                        continue
                    }
                    _ = try? database.run(linkTable.insert(link))
                    current[link.id] = link
                }
            }
            persistence.links = current
        }
        
    }
    
    struct CateringDatabase {
        static let date = Expression<Date>("date")
        static let items = Expression<Data>("items")
        static let transactionTable = Table("Transactions")
        
        static func createTable(database: Connection) {
            _ = try? database.run(transactionTable.create(ifNotExists: true,
                                        block: { tbd in
                tbd.column(date, primaryKey: true)
                tbd.column(items)
            }))
        }
        
        static func getCatering(database: Connection) -> Catering {
            let balance = PersistenceDatabase.domainDefaults.double(forKey: "CateringBalance")
            let query = transactionTable.select(
                date,
                items
            )
            let decoder = JSONDecoder()
            var transactions = [Catering.Transaction]()
            do {
                for transactionStub in try database.prepare(query) {
                    let date = transactionStub[date]
                    let data = transactionStub[items]
                    let items = try decoder.decode([Catering.Transaction.Item].self, from: data)
                    let transaction = Catering.Transaction(date: date, items: items)
                    transactions.append(transaction)
                }
            } catch {}
            return .init(balance: balance, transactions: transactions)
        }
        
        static func saveCatering(catering: Catering) {
            PersistenceDatabase.domainDefaults.set(catering.balance, forKey: "CateringBalance")
            let shared = PersistenceDatabase.shared
            let old = shared.catering
            let database = shared.database
            let oldDates = old.transactions.map { $0.date! }
            
            let encoder = JSONEncoder()
            try? database.transaction {
                for transaction in catering.transactions where !oldDates.contains(transaction.date!) {
                    do {
                        let data = try encoder.encode(transaction.items)
                        _ = try? database.run(transactionTable.insert(
                            date <- transaction.date!,
                            items <- data
                        ))
                    } catch {}
                }
            }
            shared.catering = catering
            
            if old.balance.sign == .plus && catering.balance.sign == .minus {
                NotificationManager.shared.notifyLowBalance(balance: catering.stringBalance)
            }
        }
    }
    
    struct AttendanceDatabase {
        
        enum AttendanceType: Int {
            case lesson = 0
            case statutory = 1
        }
        
        static let attendanceTable = Table("Attendance")
        static let attendance = Expression<Data>("attendance")
        static let type = Expression<AttendanceType.RawValue>("type")
        
        static func createTable(database: Connection) {
            _ = try? database.run(attendanceTable.create(ifNotExists: true,
                                                         block: { tbd in
                tbd.column(attendance)
                tbd.column(type)
            }))
        }
        
        static func saveAttendance(attendance: Attendance) {
            let shared = PersistenceDatabase.shared
            let database = shared.database
            
            try? database.transaction {
                _ = try database.prepare("DELETE from Attendance")
                
                let encoder = JSONEncoder()
                for lesson in attendance.lesson {
                    let data = try encoder.encode(lesson)
                    _ = try database.run(attendanceTable.insert(
                        AttendanceDatabase.attendance <- data,
                        type <- 0
                    ))
                }
                
                for lesson in attendance.statutory {
                    let data = try encoder.encode(lesson)
                    _ = try database.run(attendanceTable.insert(
                        AttendanceDatabase.attendance <- data,
                        type <- 1
                    ))
                }
            }
        }
        
        static func getAttendance(database: Connection) -> Attendance {
            let query = attendanceTable.select(
                attendance,
                type
            )
            let decoder = JSONDecoder()
            var lessons = [Attendance.Lesson]()
            var statutory = [Attendance.Lesson]()
            do {
                for attendance in try database.prepare(query) {
                    let lesson = try decoder.decode(Attendance.Lesson.self, from: attendance[AttendanceDatabase.attendance])
                    switch AttendanceType(rawValue: attendance[type]) {
                    case .lesson: lessons.append(lesson)
                    case .statutory: statutory.append(lesson)
                    case .none: break
                    }
                }
            } catch {}
            
            lessons.sort { $0.lesson < $1.lesson }
            statutory.sort { $0.lesson > $1.lesson }
            return .init(lesson: lessons, statutory: statutory)
        }
        
    }

}

extension URL: Value {

    public static var declaredDatatype: String {
        String.declaredDatatype
    }

    public static func fromDatatypeValue(_ stringValue: String) -> URL {
        URL(string: stringValue)!
    }

    public var datatypeValue: String {
        absoluteString
    }

}

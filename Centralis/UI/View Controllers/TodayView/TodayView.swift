//
//  TodayView.swift
//  Centralis
//
//  Created by Andromeda on 27/08/2021.
//

import UIKit

protocol Cell {}

class TodayView: UITableView {

    struct LessonCell: Cell {
        enum Context {
            case current
            case upcoming
        }
        
        let context: Context
        let subject: String
        let location: String
        let teacher: String
    }
    
    struct HomeworkCell: Cell {
        let due_text: String
        let activity: String
        let subject: String
    }
    
    struct CateringCell: Cell {
        let transactions: Int
        let balance: Double
    }
    
    struct MessageCell: Cell {
        let subject: String
        let employee_id: String?
        let sender_name: String
        let date: Date
    }
    
    struct Section {
        var footer: String?
        var header: String?
        var cells: [Cell]
    }
    
    static let shared = TodayView(frame: .zero, style: .insetGrouped)
    public var sections = [Section]()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        backgroundColor = .centralisViewColor
        tintColor = .centralisTintColor
        translatesAutoresizingMaskIntoConstraints = false
        dataSource = self
        delegate = self
        register(TodayLessonCell.self, forCellReuseIdentifier: "Centralis.TodayLessonCell")
    }
    
    public func reloadTodayData() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [self] in
                reloadTodayData()
            }
            return
        }
        var sections = [Section]()
        let shared = EduLinkAPI.shared
        
        if shared.status.current != nil || shared.status.upcoming != nil {
            var cells = [LessonCell]()
            if let current = shared.status.current,
               let subject = current.teaching_group?.subject,
               let location = current.room?.name,
               let teacher = current.teacher?.name {
                cells.append(LessonCell(context: .current, subject: subject, location: location, teacher: teacher))
            }
            if let upcoming = shared.status.upcoming,
               let subject = upcoming.teaching_group?.subject,
               let location = upcoming.room?.name,
               let teacher = upcoming.teacher?.name {
                cells.append(LessonCell(context: .upcoming, subject: subject, location: location, teacher: teacher))
            }
            if !cells.isEmpty {
                sections.append(Section(footer: nil, header: "Lessons", cells: cells))
            }
        }
        
        if !shared.homework.current.isEmpty {
            let cells: [HomeworkCell] = shared.homework.current.compactMap { homework in
                guard let due_text = homework.due_text,
                      let subject = homework.subject else { return nil }
                return HomeworkCell(due_text: due_text, activity: homework.activity ?? "Non Given", subject: subject)
            }
            if !cells.isEmpty {
                sections.append(Section(footer: nil, header: "Homework", cells: cells))
            }
        }
        
        if let catering = shared.catering {
            let cell = CateringCell(transactions: catering.transactions.count, balance: catering.balance)
            sections.append(Section(footer: nil, header: "Catering", cells: [cell]))
        }
        
        if !shared.messages.isEmpty {
            let messages = Array(shared.messages.prefix(5))
            let cells: [MessageCell] = messages.compactMap { MessageCell(subject: $0.subject, employee_id: nil, sender_name: $0.sender.name, date: $0.date) }
            sections.append(Section(footer: nil, header: "Messages", cells: cells))
        }
        
        self.sections = sections
        reloadData()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        dataPull()
    }
    
    public func dataPull() {
        if EduLinkAPI.shared.authorisedUser.authToken == nil { return }
        EduLink_Status.status { [weak self] success, error in
            if success {
                self?.reloadTodayData()
            }
        }
        EduLink_Homework.homework { [weak self] success, error in
            if success {
                self?.reloadTodayData()
            }
        }
        EduLink_Catering.catering { [weak self] success, error in
            if success {
                self?.reloadTodayData()
            }
        }
        EduLink_Messages.messages { [weak self] success, error in
            if success {
                self?.reloadTodayData()
            } else {
                NSLog("[Centralis] Error = \(error)")
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TodayView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sections[indexPath.section].cells[indexPath.row]
        let todayCell = tableView.dequeueReusableCell(withIdentifier: "Centralis.TodayLessonCell", for: indexPath) as! TodayLessonCell
        if let lessonCell = cell as? LessonCell {
            todayCell.lesson = lessonCell
            return todayCell
        } else if let homeworkCell = cell as? HomeworkCell {
            todayCell.homework = homeworkCell
            return todayCell
        } else if let cateringCell = cell as? CateringCell {
            todayCell.catering = cateringCell
            return todayCell
        } else if let messageCell = cell as? MessageCell {
            todayCell.message = messageCell
            return todayCell
        }
        fatalError("Not yet implemented")
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        sections[section].footer
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let text = self.tableView(tableView, titleForHeaderInSection: section) else { return nil }
        let headerView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 320, height: 36)))
        let label = UILabel(frame: CGRect(x: 5, y: 0, width: 320, height: 36))
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.text = text
        label.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        self.tableView(tableView, titleForHeaderInSection: section) == nil ? 0 : 36
    }
}


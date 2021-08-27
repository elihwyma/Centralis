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
        
        var subject: String
        var location: String
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TodayView: UITableViewDelegate {
    
}

extension TodayView: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    
}

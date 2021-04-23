//
//  HomeMenuLessonCell.swift
//  Centralis
//
//  Created by AW on 02/01/2021.
//

import UIKit

class HomeMenuLessonCell: UITableViewCell {
    
    
    @IBOutlet weak var currentLesson: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentRoom: UILabel!
    @IBOutlet weak var upcomingLesson: UILabel!
    @IBOutlet weak var upcomingTimeLabel: UILabel!
    @IBOutlet weak var upcomingRoom: UILabel!
    
    @IBInspectable weak var minHeight: NSNumber! = 125
    @IBOutlet weak var currentView: UIView!
    @IBOutlet weak var upcomingView: UIView!
    
    var heartbeat: Timer?
    var lessons: HomeScreenLesson?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setup()
    }
    
    private func setup() {
        self.currentView.layer.masksToBounds = true
        self.upcomingView.layer.masksToBounds = true
        self.currentView.layer.cornerRadius = 10
        self.upcomingView.layer.cornerRadius = 10
        self.currentLesson.adjustsFontSizeToFitWidth = true
        self.upcomingLesson.adjustsFontSizeToFitWidth = true
        self.currentRoom.adjustsFontSizeToFitWidth = true
        self.upcomingRoom.adjustsFontSizeToFitWidth = true
        self.currentTimeLabel.adjustsFontSizeToFitWidth = true
        self.upcomingTimeLabel.adjustsFontSizeToFitWidth = true
    }
    
    public func lessons(_ lessons: HomeScreenLesson) {
        self.heartbeat?.invalidate()
        self.lessons = lessons
        self.currentLesson.text = lessons.current.subject ?? "Not Given"
        self.currentRoom.text = lessons.current.room ?? "Not Given"
        self.upcomingLesson.text = lessons.upcoming.subject ?? "Not Given"
        self.upcomingRoom.text = lessons.upcoming.room ?? "Not Given"
        self.timeSorting()
        self.heartbeat = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timeSorting), userInfo: nil, repeats: true)
        
        self.currentView.backgroundColor = .centralisBackgroundColor
        self.upcomingView.backgroundColor = .centralisBackgroundColor
        self.currentLesson.textColor = .centralisTintColor
        self.currentTimeLabel.textColor = .centralisTintColor
        self.currentRoom.textColor = .centralisTintColor
        self.upcomingLesson.textColor = .centralisTintColor
        self.upcomingRoom.textColor = .centralisTintColor
        self.upcomingTimeLabel.textColor = .centralisTintColor
    }
    
    @objc private func timeSorting() {
        if self.lessons == nil { return }
        if self.lessons?.current.startDate != nil {
            self.currentTimeLabel.text = "Started \(Date().minutesBetweenDates((self.lessons?.current.startDate!)!, true)) minutes ago"
        }
        if self.lessons?.upcoming.startDate != nil {
            self.upcomingTimeLabel.text = "Starts in \(Date().minutesBetweenDates((self.lessons?.upcoming.startDate!)!, false)) minutes"
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
        guard let minHeight = minHeight else { return size }
        return CGSize(width: size.width, height: max(size.height, (minHeight as! CGFloat)))
    }
}

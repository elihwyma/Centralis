//
//  PagingDetailController.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

class CarouselController: UIPageViewController {
    
    private var views = [UIViewController]()
    var context: CarouselContext?
    var senderContext: CarouselContainerController?
    var week: Week?
    
    var currentIndex: Int {
        guard let vc = viewControllers?.first else { return 0 }
        return views.firstIndex(of: vc) ?? 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    public func setup() {        
        switch context {
        case .homework: self.homeworkSetup()
        case .timetable: self.timetableSetup()
        case .behaviour: self.behaviourSetup()
        case .attendance: self.attendanceSetup()
        case .none: break
        }
                
        self.dataSource = self
        self.delegate = self
        self.decoratePageControl()
    }
    
    private func decoratePageControl() {
        let pc = UIPageControl.appearance(whenContainedInInstancesOf: [CarouselController.self])
        pc.currentPageIndicatorTintColor = .lightGray
        pc.pageIndicatorTintColor = .darkGray
    }
    
    @objc private func goBack() {
        self.senderContext?.navigationController?.popViewController(animated: true)
    }
    
    private func error(_ error: String) {
        let errorView: ErrorView = .fromNib()
        errorView.text.text = error
        errorView.goBackButton.addTarget(self, action: #selector(self.goBack), for: .touchUpInside)
        switch context {
        case .homework: errorView.retryButton.addTarget(self, action: #selector(self.homeworkSetup), for: .touchUpInside)
        case .timetable: errorView.retryButton.addTarget(self, action: #selector(self.timetableSetup), for: .touchUpInside)
        case .behaviour: errorView.retryButton.addTarget(self, action: #selector(self.behaviourSetup), for: .touchUpInside)
        case .attendance: errorView.retryButton.addTarget(self, action: #selector(self.attendanceSetup), for: .touchUpInside)
        case .none: break
        }
        if let nc = self.senderContext?.navigationController { errorView.startWorking(nc) }
    }
}

//MARK: - Homework
extension CarouselController {
    @objc private func homeworkSetup() {
        self.senderContext?.activityIndicator.isHidden = false
        if !(EduLinkAPI.shared.homework.current.isEmpty && EduLinkAPI.shared.homework.past.isEmpty) {
            self.setupHomeworkViews()
            self.senderContext?.activityIndicator.isHidden = true
        } else {
            EduLink_Homework.homework({(success, error) -> Void in
                DispatchQueue.main.async {
                    self.senderContext?.activityIndicator.isHidden = true
                    if success {
                        self.setupHomeworkViews()
                    } else {
                        self.error(error!)
                    }
                }
            })
        }
    }
    
    private func setupHomeworkViews() {
        self.views.removeAll()
        let current = UIViewController()
        let cview: HomeworkTableViewController = .fromNib()
        cview.context = .current
        cview.sender = self
        cview.rootSender = self.senderContext
        current.view = cview
        self.views.append(current)
        
        let past = UIViewController()
        let pview: HomeworkTableViewController = .fromNib()
        pview.context = .past
        pview.sender = self
        pview.rootSender = self.senderContext
        past.view = pview
        self.views.append(past)
        if let firstViewController = self.views.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: false, completion: nil)
        }
    }
}

//MARK: - Timetable
extension CarouselController {
    @objc private func timetableSetup() {
        self.senderContext?.activityIndicator.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(weekChange), name: .TimetableButtonPressed, object: nil)
        if !EduLinkAPI.shared.weeks.isEmpty {
            self.ugh()
            self.senderContext?.activityIndicator.isHidden = true
        } else {
            EduLink_Timetable.timetable({(success, error) -> Void in
                DispatchQueue.main.async {
                    self.senderContext?.activityIndicator.isHidden = true
                    if success {
                        self.ugh()
                    } else {
                        self.error(error!)
                    }
                }
            })
        }
    }
    
    @objc private func ugh() { self.setupTimetable(nil) }
    
    private func setupTimetable(_ name: String?) {
        DispatchQueue.main.async {
            if let name = name {
                self.week = EduLinkAPI.shared.weeks.first(where: { $0.name == name })
            } else {
                self.week = EduLinkAPI.shared.weeks.first(where: { $0.is_current == true })
            }
            
            if self.week == nil {
                if EduLinkAPI.shared.weeks.count == 0 {
                    return
                } else {
                    self.week = EduLinkAPI.shared.weeks.first
                }
            }
            self.views.removeAll()
            for day in self.week!.days {
                let vc = UIViewController()
                let tview: EmbeddedTableViewController = .fromNib()
                tview.day = day
                tview.context = .timetable
                vc.view = tview
                self.views.append(vc)
            }
            var vc: UIViewController?
            for (index, day) in self.week!.days.enumerated() where day.isCurrent {
                vc = self.views[index]
            }
            if vc == nil {
                if let c = self.views.first {
                    vc = c
                } else {
                    return
                }
            }
            self.setViewControllers([vc!], direction: .forward, animated: false, completion: { Void in
                self.title()
                self.timetableButtonName()
            })
        }
    }
    
    private func timetableButtonName() {
        if self.senderContext == nil || self.week == nil { return }
        self.senderContext!.rightNavigationButton.setTitle(self.week!.name!, for: .normal)
    }
    
    @objc private func weekChange() {
        if self.senderContext == nil { return }
        let alert = UIAlertController(title: "Week", message: "Which week do you want to view?", preferredStyle: .actionSheet)
        for week in EduLinkAPI.shared.weeks {
            alert.addAction(UIAlertAction(title: week.name, style: .default, handler: { action in
                self.setupTimetable(week.name)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.senderContext!.view
            popoverController.sourceRect = CGRect(x: self.senderContext!.view.bounds.midX, y: self.senderContext!.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        self.senderContext?.present(alert, animated: true)
    }
}

//MARK: - Behaviour
extension CarouselController {
    @objc private func behaviourSetup() {
        self.senderContext?.activityIndicator.isHidden = true
        if !EduLinkAPI.shared.achievementBehaviourLookups.behaviours.isEmpty {
            self.setupBehaviourViews()
            self.senderContext?.activityIndicator.isHidden = true
        } else {
            EduLink_Achievement.behaviour({(success, error) -> Void in
                DispatchQueue.main.async {
                    self.senderContext?.activityIndicator.isHidden = true
                    if success {
                        self.setupBehaviourViews()
                    } else {
                        self.error(error!)
                    }
                }
            })
        }
    }
    
    private func setupBehaviourViews() {
        self.views.removeAll()
        let behaviour = UIViewController()
        let bview: EmbeddedTableViewController = .fromNib()
        bview.context = .behaviour
        behaviour.view = bview
        self.views.append(behaviour)
        
        let lessonBehaviour = UIViewController()
        let lbview: ChartTableViewController = .fromNib()
        lbview.context = .lessonBehaviour
        lessonBehaviour.view = lbview
        self.views.append(lessonBehaviour)
        
        let detentions = UIViewController()
        let dview: EmbeddedTableViewController = .fromNib()
        dview.context = .detention
        detentions.view = dview
        self.views.append(detentions)
        
        if let firstViewController = self.views.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: false, completion: { Void in
                self.behaviourTitle()
            })
        }
    }
}

//MARK: - Attendance
extension CarouselController {
    @objc private func attendanceSetup() {
        self.senderContext?.activityIndicator.isHidden = true
        if !EduLinkAPI.shared.attendance.lessons.isEmpty || !EduLinkAPI.shared.attendance.statutory.isEmpty {
            self.setupAttendanceViews()
            self.senderContext?.activityIndicator.isHidden = true
        } else {
            EduLink_Attendance.attendance({(success, error) -> Void in
                DispatchQueue.main.async {
                    self.senderContext?.activityIndicator.isHidden = true
                    if success {
                        self.setupAttendanceViews()
                    } else {
                        self.error(error!)
                    }
                }
            })
        }
    }
    
    private func setupAttendanceViews() {
        self.views.removeAll()
        if EduLinkAPI.shared.attendance.show_lesson {
            let lessonattendance = UIViewController()
            let lview: ChartTableViewController = .fromNib()
            lview.context = .lessonattendance
            lessonattendance.view = lview
            self.views.append(lessonattendance)
        }
        if EduLinkAPI.shared.attendance.show_statutory {
            let statutorymonth = UIViewController()
            let sm: ChartTableViewController = .fromNib()
            sm.context = .statutorymonth
            statutorymonth.view = sm
            self.views.append(statutorymonth)
            
            let statutoryyear = UIViewController()
            let sy: ChartTableViewController = .fromNib()
            sy.context = .statutoryyear
            statutoryyear.view = sy
            self.views.append(statutoryyear)
        }

        if let firstViewController = self.views.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: false, completion: { Void in
                self.title()
            })
        }
    }
}

//MARK: - Carousel Delegate
extension CarouselController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var index = self.views.firstIndex(of: viewController) else {
            return nil
        }
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        index -= 1
        return self.views[index]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = self.views.firstIndex(of: viewController) else {
            return nil
        }
        if index == NSNotFound {
            return nil
        }
        index += 1
        if index == self.views.count {
            return nil
        }
        return self.views[index]
    }
    
    func presentationCount(for _: UIPageViewController) -> Int {
        return self.views.count
    }
    
    func presentationIndex(for _: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
              let firstViewControllerIndex = self.views.firstIndex(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}

extension CarouselController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed { return }
        self.title()
    }
    
    private func title() {
        switch context {
        case .timetable: do {
            if self.week == nil || self.senderContext == nil { return }
            let index = self.currentIndex
            self.senderContext!.title = self.week!.days[index].name!
        }
        case .behaviour: do {
            let index = self.currentIndex
            switch index {
            case 0: self.behaviourTitle()
            case 1: self.senderContext!.title = "Lesson Behaviour"
            case 2: self.senderContext!.title = "Detentions"
            default: break
            }
        }
        case .attendance: do {
            let index = self.currentIndex
            if EduLinkAPI.shared.attendance.show_lesson && index == 0 {
                self.senderContext!.title = "Lesson Attendance"
            } else if (EduLinkAPI.shared.attendance.show_statutory && EduLinkAPI.shared.attendance.show_lesson && index == 1) || (EduLinkAPI.shared.attendance.show_statutory && !EduLinkAPI.shared.attendance.show_lesson && index == 0) {
                self.senderContext!.title = "Statutory Month"
            } else if (EduLinkAPI.shared.attendance.show_statutory && EduLinkAPI.shared.attendance.show_lesson && index == 2) || (EduLinkAPI.shared.attendance.show_statutory && !EduLinkAPI.shared.attendance.show_lesson && index == 1) {
                self.senderContext!.title = "Statutory Year"
            }
        }
        default: break
        }
    }
    
    private func behaviourTitle() {
        var count = 0
        for behaviour in EduLinkAPI.shared.achievementBehaviourLookups.behaviours {
            count += behaviour.points
        }
        self.senderContext!.title = "Behaviour: \(count)"
    }
}

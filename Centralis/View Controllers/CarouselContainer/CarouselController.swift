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
}

//MARK: - Homework
extension CarouselController {
    private func homeworkSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupHomeworkViews), name: .SuccesfulHomework, object: nil)
        let homework = EduLink_Homework()
        homework.homework()
        if !(EduLinkAPI.shared.homework.current.isEmpty && EduLinkAPI.shared.homework.past.isEmpty) {
            self.setupHomeworkViews()
        }
    }
    
    @objc private func setupHomeworkViews() {
        DispatchQueue.main.async {
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
}

//MARK: - Timetable
extension CarouselController {
    private func timetableSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(weekChange), name: .TimetableButtonPressed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ugh), name: .SuccesfulTimetable, object: nil)
        let timetable = EduLink_Timetable()
        timetable.timetable()
        if !EduLinkAPI.shared.weeks.isEmpty {
            self.ugh()
            self.senderContext?.activityIndicator.isHidden = true
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
    private func behaviourSetup() {
        NotificationCenter.default.addObserver(self, selector: #selector(setupBehaviourViews), name: .SucccesfulBehaviour, object: nil)
        let behaviour = EduLink_Achievement()
        behaviour.behaviour()
        if !EduLinkAPI.shared.achievementBehaviourLookups.behaviours.isEmpty {
            self.ugh()
            self.senderContext?.activityIndicator.isHidden = true
        }
    }
    
    @objc private func setupBehaviourViews() {
        DispatchQueue.main.async {
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
            
            if let firstViewController = self.views.first {
                self.setViewControllers([firstViewController], direction: .forward, animated: false, completion: { Void in
                    self.behaviourTitle()
                })
            }
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
            default: break
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

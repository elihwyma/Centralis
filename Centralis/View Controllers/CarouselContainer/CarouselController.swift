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
        let homework = EduLink_Homework()
        homework.homework()
        
        self.views.removeAll()
        let current = UIViewController()
        let cview: HomeworkTableViewController = .fromNib()
        cview.context = .current
        cview.sender = self
        current.view = cview
        self.views.append(current)
        
        let past = UIViewController()
        let pview: HomeworkTableViewController = .fromNib()
        pview.context = .past
        pview.sender = self
        past.view = pview
        self.views.append(past)

        if let firstViewController = self.views.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
}

//MARK: - Timetable
extension CarouselController {
    private func timetableSetup() {
        let timetable = EduLink_Timetable()
        timetable.timetable()
        NotificationCenter.default.addObserver(self, selector: #selector(ugh), name: .SuccesfulTimetable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(weekChange), name: .TimetableButtonPressed, object: nil)
    }
    
    @objc private func ugh() { self.setupTimetable(nil) }
    
    private func setupTimetable(_ name: String?) {
        DispatchQueue.main.async {
            if let name = name {
                for w in EduLinkAPI.shared.weeks where w.name == name {
                    self.week = w
                }
            } else {
                for w in EduLinkAPI.shared.weeks where w.is_current {
                    self.week = w
                }
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
                let tview: TimetableTableViewController = .fromNib()
                tview.day = day
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
            self.setViewControllers([vc!], direction: .forward, animated: true, completion: { Void in
                self.title()
                self.buttonName()
            })
        }
    }
    
    private func buttonName() {
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
        default: break
        }
    }
}

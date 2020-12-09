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
        self.decoratePageControl()
        if let firstViewController = self.views.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
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
    }
}

//MARK: - Timetable
extension CarouselController {
    private func timetableSetup() {
        let timetable = EduLink_Timetable()
        timetable.timetable()
    }
    
    private func setupTimetable(name: String?) {
        var week: Week?
        if let name = name {
            for w in EduLinkAPI.shared.weeks where w.name == name {
                week = w
            }
        } else {
            for w in EduLinkAPI.shared.weeks where w.is_current {
                week = w
            }
        }
        if week == nil { return }
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

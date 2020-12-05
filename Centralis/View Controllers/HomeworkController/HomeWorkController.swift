//
//  PagingDetailController.swift
//  Centralis
//
//  Created by Amy While on 05/12/2020.
//

import UIKit

class HomeWorkController: UIPageViewController {
    
    private var views = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }
    
    private func setup() {
        let homework = EduLink_Homework()
        homework.homework()
        self.dataSource = self
        self.decoratePageControl()
        self.setupViews()
        if let firstViewController = self.views.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func setupViews() {
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
    
    private func decoratePageControl() {
        let pc = UIPageControl.appearance(whenContainedInInstancesOf: [HomeWorkController.self])
        pc.currentPageIndicatorTintColor = .lightGray
        pc.pageIndicatorTintColor = .darkGray
    }
}

extension HomeWorkController: UIPageViewControllerDataSource {
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

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

        // Do any additional setup after loading the view.
        self.setup()
    }
    
    private func setup() {
        let homework = EduLink_Homework()
        homework.homework()
        self.dataSource = self
        self.decoratePageControl()
        self.setupViews()
    }
    
    private func setupViews() {
        self.views.removeAll()
        let current = UIViewController()
        current.view = HomeworkTable(context: .current)
        self.views.append(current)
        
        let past = UIViewController()
        past.view = HomeworkTable(context: .past)
        self.views.append(past)
    }
    
    private func decoratePageControl() {
        let pc = UIPageControl.appearance(whenContainedInInstancesOf: [HomeWorkController.self])
        pc.currentPageIndicatorTintColor = .lightGray
        pc.pageIndicatorTintColor = .darkGray
    }
}

extension HomeWorkController: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.views.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return self.views.last
        }
        
        guard self.views.count > previousIndex else {
            return nil
        }
        
        return self.views[previousIndex]
    }
    
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = self.views.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard self.views.count != nextIndex else {
            return self.views.first
        }
        
        guard self.views.count > nextIndex else {
            return nil
        }
        
        return self.views[nextIndex]
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

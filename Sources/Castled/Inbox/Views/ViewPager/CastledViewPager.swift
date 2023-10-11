
//  CastledViewPager.swift
//  CategoriesTabPOC
//
//  Created by antony on 10/10/2023.
//

import Foundation
import UIKit

protocol CastledViewPagerDataSource: AnyObject {
    func numberOfPagesInViewPager() -> Int

    func getViewControllerAtIndex(index: Int) -> UIViewController

    func getTabBarItems() -> [CastledViewPagerTabItem]

    func getInitialPageViewIndex() -> Int
}

protocol CastledViewPagerDelegate: AnyObject {
    func didMoveToControllerAtIndex(index: Int)
}

class CastledViewPager: NSObject {
    private weak var dataSource: CastledViewPagerDataSource?
    private weak var delegate: CastledViewPagerDelegate?
    private weak var controller: UIViewController?
    private var parentView: UIView

    private var scrollTabContainer = UIScrollView()
    private var pageController: UIPageViewController?

    private var viewCurrentSelectiionIndicater = UIView()
    private var constraintTabIndicatorLeading: NSLayoutConstraint?
    private var constraintTabIndicatorWidth: NSLayoutConstraint?

    private var tabBarItems = [CastledViewPagerTabItem]()
    private var tabBarViews = [CastledViewPagerTabView]()

    private var configs = CastledViewPagerDisplayConfigs()
    private var currentPageIndex = 0

    // MARK: - Initialization

    init(viewController: UIViewController, containerView: UIView? = nil) {
        self.controller = viewController
        self.parentView = containerView ?? viewController.view
    }

    func setDisplayConfigs(config: CastledViewPagerDisplayConfigs) {
        configs = config
    }

    func setDataSource(dataSource: CastledViewPagerDataSource) {
        self.dataSource = dataSource
    }

    func setDelegate(delegate: CastledViewPagerDelegate?) {
        self.delegate = delegate
    }

    func setupViews() {
        setupTabContainerScrollView()
        setupPageViewController()
        createTabs()
    }

    // MARK: -  Helper Classes

    private func setupTabContainerScrollView() {
        scrollTabContainer.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(scrollTabContainer)

        scrollTabContainer.backgroundColor = configs.tabBarDefaultColor
        scrollTabContainer.isScrollEnabled = true
        scrollTabContainer.showsVerticalScrollIndicator = false
        scrollTabContainer.showsHorizontalScrollIndicator = false

        if configs.hideTabBar {
            scrollTabContainer.heightAnchor.constraint(equalToConstant: 0).isActive = true

        } else {
            scrollTabContainer.heightAnchor.constraint(equalToConstant: configs.tabBarHeight).isActive = true
        }

        scrollTabContainer.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        scrollTabContainer.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        scrollTabContainer.widthAnchor.constraint(equalTo: parentView.widthAnchor).isActive = true

        if #available(iOS 11.0, *) {
            if let topBarInContainer = configs.viewTopAlignmentView {
                scrollTabContainer.topAnchor.constraint(equalTo: topBarInContainer.bottomAnchor).isActive = true

            } else {
                let safeArea = parentView.safeAreaLayoutGuide
                scrollTabContainer.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
            }
        } else {
            let marginGuide = parentView.layoutMarginsGuide
            scrollTabContainer.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        }

        let tabBarTapGesture = UITapGestureRecognizer(target: self, action: #selector(tabContainerScrollViewTapped(_:)))
        scrollTabContainer.addGestureRecognizer(tabBarTapGesture)
    }

    private func removeSwipeGesture() {
        for view in pageController!.view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = false
            }
        }
    }

    private func setupPageViewController() {
        let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        controller?.addChild(pageController)

        setupForAutolayout(view: pageController.view, inView: parentView)
        pageController.didMove(toParent: controller)
        self.pageController = pageController

        self.pageController?.dataSource = self
        self.pageController?.delegate = self

        self.pageController?.view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        self.pageController?.view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        self.pageController?.view.topAnchor.constraint(equalTo: scrollTabContainer.bottomAnchor).isActive = true
        self.pageController?.view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true

        guard let viewPagerDataSource = dataSource else {
            fatalError("CastledViewPager DataSource not set")
        }

        currentPageIndex = viewPagerDataSource.getInitialPageViewIndex()
        if let firstPageController = getCurrentViewController(atIndex: currentPageIndex) {
            self.pageController?.setViewControllers([firstPageController], direction: .forward, animated: false, completion: nil)
        }
        if configs.disableContainerScroll {
            removeSwipeGesture()
        }
    }

    // MARK: - CastledViewPager Tab Setup

    private func createTabs() {
        guard let tabs = dataSource?.getTabBarItems() else { return }
        tabBarItems = tabs
        setupTabs()

        setupForAutolayout(view: viewCurrentSelectiionIndicater, inView: scrollTabContainer)
        viewCurrentSelectiionIndicater.backgroundColor = configs.tabBarIndicatorBackgroundColor
        if configs.hideTabBar {
            viewCurrentSelectiionIndicater.heightAnchor.constraint(equalToConstant: 0).isActive = true
        } else {
            viewCurrentSelectiionIndicater.heightAnchor.constraint(equalToConstant: 3).isActive = true
        }
        viewCurrentSelectiionIndicater.bottomAnchor.constraint(equalTo: scrollTabContainer.bottomAnchor).isActive = true

        let currentTab = tabBarViews[currentPageIndex]

        constraintTabIndicatorLeading = viewCurrentSelectiionIndicater.leadingAnchor.constraint(equalTo: currentTab.leadingAnchor)
        constraintTabIndicatorWidth = viewCurrentSelectiionIndicater.widthAnchor.constraint(equalTo: currentTab.widthAnchor)

        constraintTabIndicatorLeading?.isActive = true
        constraintTabIndicatorWidth?.isActive = true

        tabBarViews[currentPageIndex].addHighlight(config: configs)

        scrollTabContainer.layer.masksToBounds = false
        scrollTabContainer.layer.shadowColor = UIColor.black.cgColor
        scrollTabContainer.layer.shadowOpacity = 0.3
        scrollTabContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        scrollTabContainer.layer.shadowRadius = 2

        parentView.bringSubviewToFront(scrollTabContainer)
    }

    private func setupTabs() {
        var maxWidth: CGFloat = 0
        var contentWidth: CGFloat = 0

        var lastTab: CastledViewPagerTabView?

        for (index, tab) in tabBarItems.enumerated() {
            let tabBarView = CastledViewPagerTabView()
            setupForAutolayout(view: tabBarView, inView: scrollTabContainer)

            tabBarView.backgroundColor = configs.tabBarDefaultColor
            tabBarView.setup(tab: tab, config: configs)

            if let previousTab = lastTab {
                tabBarView.leadingAnchor.constraint(equalTo: previousTab.trailingAnchor).isActive = true
            } else {
                tabBarView.leadingAnchor.constraint(equalTo: scrollTabContainer.leadingAnchor).isActive = true
            }

            tabBarView.topAnchor.constraint(equalTo: scrollTabContainer.topAnchor).isActive = true
            tabBarView.bottomAnchor.constraint(equalTo: scrollTabContainer.bottomAnchor).isActive = true
            if configs.hideTabBar {
                tabBarView.heightAnchor.constraint(equalToConstant: 0).isActive = true

            } else {
                tabBarView.heightAnchor.constraint(equalToConstant: configs.tabBarHeight).isActive = true
            }

            tabBarView.tag = index
            tabBarViews.append(tabBarView)

            maxWidth = max(maxWidth, tabBarView.width)
            contentWidth += tabBarView.width
            lastTab = tabBarView
        }

        lastTab?.trailingAnchor.constraint(equalTo: scrollTabContainer.trailingAnchor).isActive = true
        let numberOfItems = dataSource?.numberOfPagesInViewPager()

        tabBarViews.forEach { tabItem in

            if configs.isEqualWidth {
                if CGFloat(CGFloat(numberOfItems!) * maxWidth) < UIScreen.main.bounds.width {
                    maxWidth = UIScreen.main.bounds.width / CGFloat(numberOfItems!)
                }
                tabItem.widthAnchor.constraint(equalToConstant: maxWidth).isActive = true

            } else {
                if CGFloat(contentWidth) < UIScreen.main.bounds.width {
                    tabItem.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / CGFloat(numberOfItems!)).isActive = true
                } else {
                    tabItem.widthAnchor.constraint(equalToConstant: tabItem.width).isActive = true
                }
            }
        }
    }

    // method for displaying the current item selection
    private func setupCurrentPageIndicator(currentIndex: Int, previousIndex: Int) {
        currentPageIndex = currentIndex

        let currentTab = tabBarViews[currentIndex]
        let currentFrame = currentTab.frame

        tabBarViews[previousIndex].removeHighlight(config: configs)

        UIView.animate(withDuration: 0.4, animations: {
            self.tabBarViews[currentIndex].addHighlight(config: self.configs)
        })
        constraintTabIndicatorLeading?.isActive = false
        constraintTabIndicatorWidth?.isActive = false

        constraintTabIndicatorLeading = viewCurrentSelectiionIndicater.leadingAnchor.constraint(equalTo: currentTab.leadingAnchor)
        constraintTabIndicatorWidth = viewCurrentSelectiionIndicater.widthAnchor.constraint(equalTo: currentTab.widthAnchor)

        parentView.layoutIfNeeded()
        UIView.animate(withDuration: 0.5) {
            self.constraintTabIndicatorWidth?.isActive = true
            self.constraintTabIndicatorLeading?.isActive = true

            self.scrollTabContainer.scrollRectToVisible(currentFrame, animated: false)
            self.scrollTabContainer.layoutIfNeeded()
        }
    }

    // Returns UIViewController for page at provided index.
    private func getCurrentViewController(atIndex index: Int) -> UIViewController? {
        guard let viewPagerSource = dataSource, index >= 0 && index < viewPagerSource.numberOfPagesInViewPager() else {
            return nil
        }

        let pagerViewController = viewPagerSource.getViewControllerAtIndex(index: index)
        pagerViewController.view.tag = index

        return pagerViewController
    }

    // Navigation to the current selection.
    func navigateToSelectedViewController(atIndex index: Int) {
        guard let selectedViewController = getCurrentViewController(atIndex: index) else {
            fatalError("There is no view controller for tab at index: \(index)")
        }

        let previousIndex = currentPageIndex
        let direction: UIPageViewController.NavigationDirection = (index > previousIndex) ? .forward : .reverse

        setupCurrentPageIndicator(currentIndex: index, previousIndex: currentPageIndex)
        pageController?.setViewControllers([selectedViewController], direction: direction, animated: true, completion: { _ in

            DispatchQueue.main.async { [weak self] in

                self?.pageController?.setViewControllers([selectedViewController], direction: direction, animated: false, completion: { isComplete in

                    guard isComplete else { return }

                    self?.delegate?.didMoveToControllerAtIndex(index: index)

                })
            }
        })
    }

    func getCurrentPageIndex() -> Int {
        return currentPageIndex
    }

    // Method for removing all tabs.
    func invalidateCurrentTabs() {
        // Removing all the tabs from tabContainerScrollView
        _ = tabBarViews.map({ $0.removeFromSuperview() })

        viewCurrentSelectiionIndicater = UIView()
        constraintTabIndicatorLeading?.isActive = false
        constraintTabIndicatorWidth?.isActive = false

        tabBarItems.removeAll()
        tabBarViews.removeAll()

        createTabs()
    }

    // MARK: - Actions

    @objc func tabContainerScrollViewTapped(_ recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: scrollTabContainer)
        let tabBarTapped = scrollTabContainer.hitTest(tapLocation, with: nil)
        if let tabIndex = tabBarTapped?.tag, tabIndex != currentPageIndex {
            navigateToSelectedViewController(atIndex: tabIndex)
        }
    }
}

extension CastledViewPager: UIPageViewControllerDataSource {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let previousController = getCurrentViewController(atIndex: viewController.view.tag - 1)
        return previousController
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let nextController = getCurrentViewController(atIndex: viewController.view.tag + 1)
        return nextController
    }
}

extension CastledViewPager: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let pageIndex = pageViewController.viewControllers?.first?.view.tag else { return }

        if completed && finished {
            setupCurrentPageIndicator(currentIndex: pageIndex, previousIndex: currentPageIndex)
            delegate?.didMoveToControllerAtIndex(index: pageIndex)
        }
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {}
    func setupForAutolayout(view: UIView?, inView parentView: UIView) {
        guard let v = view else { return }

        v.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(v)
    }
}

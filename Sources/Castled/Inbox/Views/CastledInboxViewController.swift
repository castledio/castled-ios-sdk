//
//  CastledInboxViewController.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import Combine
import RealmSwift
import UIKit

@objc public protocol CastledInboxViewControllerDelegate {
    @objc optional func didSelectedInboxWith(_ action: CastledClickActionType, _ kvPairs: [AnyHashable: Any]?, _ inboxItem: CastledInboxItem)
}

@objc public class CastledInboxViewController: UIViewController {
    @objc public var delegate: CastledInboxViewControllerDelegate?
    @IBOutlet weak var lblTitle: UILabel!
    var inboxConfig: CastledInboxDisplayConfig?
    @IBOutlet weak var viewTopBar: UIView!
    @IBOutlet weak var constraintTopBarHeight: NSLayoutConstraint!
    @IBOutlet weak var btnClose: UIButton!

    var viewModel = CastledInboxViewModel()
    var readItems = [Int64]()

    private var topCategories = [CastledViewPagerTabItem]()
    private var viewPager: CastledViewPager?
    private var listingViewControllers = [CastledInboxListingViewController]()
    private var cancellables: Set<AnyCancellable> = []

    override public func viewDidLoad() {
        super.viewDidLoad()
        if Castled.sharedInstance == nil {
            fatalError(CastledExceptionMessages.notInitialised.rawValue)
        }
        setupViews()
        setupTopCategories()
        bindViewModel()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateReadStatus()
    }

    private func setupViews() {
        view.backgroundColor = inboxConfig!.inboxViewBackgroundColor

        if navigationController != nil, navigationController?.isNavigationBarHidden == false {
            navigationItem.title = inboxConfig!.navigationBarTitle
            viewTopBar.isHidden = true
            constraintTopBarHeight.constant = 0
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = inboxConfig!.navigationBarBackgroundColor
            appearance.titleTextAttributes = [.foregroundColor: inboxConfig!.navigationBarButtonTintColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: inboxConfig!.navigationBarButtonTintColor]
            navigationController?.navigationBar.tintColor = inboxConfig!.navigationBarButtonTintColor
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance

            if !inboxConfig!.hideCloseButton {
                let closeButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(closeButtonTapped(_:)))
                navigationItem.rightBarButtonItem = closeButton
            }
        } else {
            viewTopBar.backgroundColor = inboxConfig!.navigationBarBackgroundColor
            modifyTopBarHeight()
            lblTitle.text = inboxConfig!.navigationBarTitle
            btnClose.tintColor = inboxConfig!.navigationBarButtonTintColor
            lblTitle.textColor = inboxConfig!.navigationBarButtonTintColor
            btnClose.isHidden = inboxConfig!.hideCloseButton
        }
    }

    private func modifyTopBarHeight() {
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top

        if navigationController != nil {
            constraintTopBarHeight.constant = (topPadding ?? 0) + 44.0
        } else {
            if modalPresentationStyle == .fullScreen {
                constraintTopBarHeight.constant = (topPadding ?? 0) + 44.0

            } else {
                constraintTopBarHeight.constant = 44.0
            }
        }
    }

    private func bindViewModel() {
        viewModel.$showLoader
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showLoader in
                if let listingControllers = self?.listingViewControllers {
                    for lisitngVc in listingControllers {
                        lisitngVc.showOrHideLoader(showLoader: showLoader)
                    }
                }
            }
            .store(in: &cancellables)
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if errorMessage != nil {
                    DispatchQueue.main.async {
                        if let listingControllers = self?.listingViewControllers {
                            for lisitngVc in listingControllers {
                                lisitngVc.setErrorTextWith(title: errorMessage)
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.didLoadNextPage()
    }

    private func setupTopCategories() {
        topCategories.append(CastledViewPagerTabItem(title: "All"))
        let tabDisplayConfig = CastledViewPagerDisplayConfigs()
        tabDisplayConfig.hideTabBar = !inboxConfig!.showCategoriesTab
        if inboxConfig!.showCategoriesTab {
            let realm = viewModel.realm
            let uniqueCategories = Set(realm.objects(CAppInbox.self)
                .filter("tag != '' && isDeleted == false")
                .distinct(by: ["tag"])
                .compactMap { $0.tag }).sorted()

            for tag in uniqueCategories {
                topCategories.append(CastledViewPagerTabItem(title: tag))
            }
            tabDisplayConfig.hideTabBar = topCategories.count == 1 ? true : false
        }

        for (index, item) in topCategories.enumerated() {
            let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: Bundle.resourceBundle(for: Castled.self)).instantiateViewController(identifier: "CastledInboxListingViewController") as! CastledInboxListingViewController
            castledInboxVC.currentCategory = item.title
            castledInboxVC.currentIndex = index
            castledInboxVC.inboxConfig = inboxConfig
            castledInboxVC.inboxViewController = self
            listingViewControllers.append(castledInboxVC)
        }
        tabDisplayConfig.tabBarDefaultTextColor = inboxConfig!.tabBarDefaultTextColor
        tabDisplayConfig.tabBarSelectedTextColor = inboxConfig!.tabBarSelectedTextColor
        tabDisplayConfig.tabBarDefaultColor = inboxConfig!.tabBarDefaultBackgroundColor
        tabDisplayConfig.tabBarSelectedColor = inboxConfig!.tabBarSelectedBackgroundColor
        tabDisplayConfig.tabBarIndicatorBackgroundColor = inboxConfig!.tabBarIndicatorBackgroundColor
        tabDisplayConfig.viewTopAlignmentView = viewTopBar

        viewPager = CastledViewPager(viewController: self)
        viewPager?.setDisplayConfigs(config: tabDisplayConfig)
        viewPager?.setDataSource(dataSource: self)
        viewPager?.setDelegate(delegate: self)
        viewPager?.setupViews()
    }

    private func updateReadStatus() {
        if !readItems.isEmpty {
            CastledStore.saveInboxIdsRead(readItems: readItems)
        }
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        Castled.sharedInstance?.dismissInboxViewController()
    }

    func removeObservers() {
        cancellables.forEach { $0.cancel() } // Cancel all subscriptions
    }

    deinit {
        removeObservers()
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        DispatchQueue.main.async {
            if !self.viewTopBar.isHidden {
                self.modifyTopBarHeight()
            }
            self.viewPager?.invalidateCurrentTabs()
        }
    }

    func getCurrentPageIndex() -> Int {
        return viewPager?.getCurrentPageIndex() ?? 0
    }
}

extension CastledInboxViewController: CastledViewPagerDataSource {
    func numberOfPagesInViewPager() -> Int {
        return listingViewControllers.count
    }

    func getViewControllerAtIndex(index: Int) -> UIViewController {
        return listingViewControllers[index]
    }

    func getTabBarItems() -> [CastledViewPagerTabItem] {
        return topCategories
    }

    func getInitialPageViewIndex() -> Int {
        0
    }
}

extension CastledInboxViewController: CastledViewPagerDelegate {
    func didMoveToControllerAtIndex(index: Int) {}
}

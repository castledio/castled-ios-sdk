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
    @objc optional func didSelectedInboxWith(_ buttonAction: CastledButtonAction, inboxItem: CastledInboxItem)
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

    private var topCategories = [String]()
    private var viewPager: CastledViewPager?
    private var listingViewControllers = [CastledInboxListingViewController]()
    private var cancellables: Set<AnyCancellable> = []
    private var currentPageIndex = 0
    private static let ALL_STRING = "All"

    override public func viewDidLoad() {
        super.viewDidLoad()

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

    private func getCategories(realm: Realm) -> [String] {
        let uniqueCategories = Set(realm.objects(CAppInbox.self)
            .filter("tag != '' && isDeleted == false")
            .distinct(by: ["tag"])
            .compactMap { $0.tag }).sorted()
        return uniqueCategories
    }

    private func setupTopCategories() {
        topCategories.append(CastledInboxViewController.ALL_STRING)
        let tabDisplayConfig = CastledViewPagerDisplayConfigs()
        tabDisplayConfig.hideTabBar = !inboxConfig!.showCategoriesTab
        if inboxConfig!.showCategoriesTab {
            topCategories.append(contentsOf: getCategories(realm: viewModel.realm))
            tabDisplayConfig.hideTabBar = topCategories.count == 1 ? true : false
        }
        tabDisplayConfig.tabBarDefaultTextColor = inboxConfig!.tabBarDefaultTextColor
        tabDisplayConfig.tabBarSelectedTextColor = inboxConfig!.tabBarSelectedTextColor
        tabDisplayConfig.tabBarDefaultColor = inboxConfig!.tabBarDefaultBackgroundColor
        tabDisplayConfig.tabBarSelectedColor = inboxConfig!.tabBarSelectedBackgroundColor
        tabDisplayConfig.tabBarIndicatorBackgroundColor = inboxConfig!.tabBarIndicatorBackgroundColor
        tabDisplayConfig.viewTopAlignmentView = viewTopBar
        createTabViews(tabDisplayConfig: tabDisplayConfig)
    }

    private func createTabViews(tabDisplayConfig: CastledViewPagerDisplayConfigs) {
        for (index, item) in topCategories.enumerated() {
            let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: Bundle.resourceBundle(for: Castled.self)).instantiateViewController(identifier: "CastledInboxListingViewController") as! CastledInboxListingViewController
            castledInboxVC.currentCategory = item
            castledInboxVC.currentIndex = index
            castledInboxVC.inboxConfig = inboxConfig
            castledInboxVC.inboxViewController = self
            listingViewControllers.append(castledInboxVC)
        }
        viewPager = CastledViewPager(viewController: self)
        viewPager?.setDataSource(dataSource: self)
        viewPager?.setDelegate(delegate: self)
        viewPager?.setDisplayConfigs(config: tabDisplayConfig)
        viewPager?.setupViews()
    }

    func updateViewPagerAfterDBChanges() {
        if !inboxConfig!.showCategoriesTab {
            return
        }
        CastledStore.castledStoreQueue.async { [weak self] in
            var currentCategories = [CastledInboxViewController.ALL_STRING]
            currentCategories.append(contentsOf: self?.getCategories(realm: CastledDBManager.shared.getRealm()) ?? [])
            if currentCategories != self?.topCategories {
                DispatchQueue.main.async { [weak self] in
                    self?.topCategories.removeAll()
                    self?.topCategories.append(contentsOf: currentCategories)
                    let tabDisplayConfig = self?.viewPager?.configs
                    tabDisplayConfig!.hideTabBar = self?.topCategories.count == 1 ? true : false
                    var lastIndex = self?.getCurrentPageIndex() ?? 0
                    if lastIndex >= currentCategories.count {
                        lastIndex = 0
                    }
                    self?.currentPageIndex = lastIndex
                    self?.viewPager?.removeChildViews()
                    self?.viewPager?.setDelegate(delegate: nil)
                    self?.listingViewControllers.forEach { $0.removeObservers() }
                    self?.listingViewControllers.removeAll()

                    self?.viewPager = nil
                    self?.createTabViews(tabDisplayConfig: tabDisplayConfig!)
                }
            }
        }
    }

    func updateReadStatus() {
        if !readItems.isEmpty {
            CastledStore.saveInboxIdsRead(readItems: readItems)
            readItems.removeAll()
        }
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        if let presentingViewController = presentingViewController {
            // If presented modally, dismiss it
            presentingViewController.dismiss(animated: true, completion: nil)
        } else if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            Castled.sharedInstance.dismissInboxViewController()
        }
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

    func getTabBarItems() -> [String] {
        return topCategories
    }

    func getInitialPageViewIndex() -> Int {
        return currentPageIndex
    }
}

extension CastledInboxViewController: CastledViewPagerDelegate {
    func didMoveToControllerAtIndex(index: Int) {}
}

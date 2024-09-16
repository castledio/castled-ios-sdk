//
//  CastledInboxViewController.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import Combine
import UIKit
@_spi(CastledInternal) import Castled
import CoreData

@objc public protocol CastledInboxViewControllerDelegate {
    @objc optional func didSelectedInboxWith(_ buttonAction: CastledButtonAction, inboxItem: CastledInboxItem)
}

@objc public class CastledInboxViewController: UIViewController {
    @objc public var delegate: CastledInboxViewControllerDelegate?
    @IBOutlet weak var lblTitle: UILabel!
    var inboxConfig: CastledInboxDisplayConfig?
    @IBOutlet weak var viewTopBar: UIView!
    @IBOutlet weak var constraintTopBarHeight: NSLayoutConstraint!
    @IBOutlet weak var btnClose: UIButton!
    let castledInboxQueue = DispatchQueue(label: "com.castled.inboxQueue")

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
        DispatchQueue.main.async { [weak self] in
            self?.setupViews()
            self?.setupTopCategories()
            self?.bindViewModel()
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        if navigationController != nil, navigationController?.isNavigationBarHidden == false {
            navigationItem.setHidesBackButton(true, animated: false)
        }
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
            navigationItem.setHidesBackButton(true, animated: false)

            if !inboxConfig!.hideBackButton {
                let closeButton = UIBarButtonItem(image: getBackButtonImage(), style: .plain, target: self, action: #selector(closeButtonTapped(_:)))
                navigationItem.leftBarButtonItem = closeButton
            }

        } else {
            viewTopBar.backgroundColor = inboxConfig!.navigationBarBackgroundColor
            modifyTopBarHeight()
            lblTitle.text = inboxConfig!.navigationBarTitle
            btnClose.tintColor = inboxConfig!.navigationBarButtonTintColor
            lblTitle.textColor = inboxConfig!.navigationBarButtonTintColor
            btnClose.isHidden = inboxConfig!.hideBackButton
            btnClose.setImage(getBackButtonImage(), for: .normal)
            btnClose.imageView?.contentMode = .scaleAspectFit
        }
    }

    private func modifyTopBarHeight() {
        var topPadding = CGFloat(0)
        if let application = UIApplication.getSharedApplication() as? UIApplication {
            let window = application.windows.first
            topPadding = window?.safeAreaInsets.top ?? CGFloat(0)
        }
        if navigationController != nil {
            constraintTopBarHeight.constant = topPadding + 44.0
        } else {
            if modalPresentationStyle == .fullScreen {
                constraintTopBarHeight.constant = topPadding + 44.0

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

    private func getCategories() -> [String] {
        let context = CastledCoreDataStack.shared.mainContext
        let column = "tag"
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CastledInboxMO.fetchRequest()
        fetchRequest.resultType = .dictionaryResultType

        // Set that you want distinct results
        fetchRequest.returnsDistinctResults = true

        // Set the column you want to fetch
        fetchRequest.propertiesToFetch = [column]

        // Set the predicate to filter items
        fetchRequest.predicate = NSPredicate(format: "tag != '' AND isRemoved == false")

        do {
            let res = try context.fetch(fetchRequest) as? [[String: Any]]
            let distinctValues = res?.compactMap { $0[column] as? String } ?? []
            return distinctValues.sorted()
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }

    private func setupTopCategories() {
        topCategories.append(CastledInboxViewController.ALL_STRING)
        let tabDisplayConfig = CastledViewPagerDisplayConfigs()
        tabDisplayConfig.hideTabBar = !inboxConfig!.showCategoriesTab
        if inboxConfig!.showCategoriesTab {
            topCategories.append(contentsOf: getCategories())
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
            let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: Bundle.resourceBundle(for: CastledInbox.self)).instantiateViewController(identifier: "CastledInboxListingViewController") as! CastledInboxListingViewController
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
        castledInboxQueue.async { [weak self] in
            var currentCategories = [CastledInboxViewController.ALL_STRING]
            currentCategories.append(contentsOf: self?.getCategories() ?? [])
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
            CastledInboxCoreDataOperations.shared.saveInboxIdsRead(readItems: readItems)
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
            CastledInbox.sharedInstance.dismissInboxViewController()
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

    private func getBackButtonImage() -> UIImage {
        let backImage = inboxConfig?.backButtonImage?.withRenderingMode(.alwaysOriginal) ?? UIImage(named: "castled_back_left", in: Bundle.resourceBundle(for: CastledInbox.self), compatibleWith: nil)!.withRenderingMode(.alwaysTemplate)
        return backImage
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

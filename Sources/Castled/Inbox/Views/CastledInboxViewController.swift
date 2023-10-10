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
        setupTopCategories()
        setupViews()
        bindViewModel()

    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateReadStatus()
    }

    private func setupViews() {
        view.backgroundColor = inboxConfig!.inboxViewBackgroundColor
        // TODO: indicatorView.color = inboxConfig!.loaderTintColor

        if navigationController?.isNavigationBarHidden == false {
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
            let window = UIApplication.shared.windows.first
            let topPadding = window?.safeAreaInsets.top
            if modalPresentationStyle == .fullScreen {
                constraintTopBarHeight.constant = (topPadding ?? 0) + 44.0

            } else {
                constraintTopBarHeight.constant = 44.0
            }
            lblTitle.text = inboxConfig!.navigationBarTitle
            btnClose.tintColor = inboxConfig!.navigationBarButtonTintColor
            lblTitle.textColor = inboxConfig!.navigationBarButtonTintColor
            btnClose.isHidden = inboxConfig!.hideCloseButton
        }
        // TODO: lblNoUpdates.text = inboxConfig!.emptyMessageViewText

        showRequiredViews()
    }

    private func bindViewModel() {
        viewModel.$showLoader
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // TODO: check below code
                /*
                 self?.indicatorView.isHidden = !showLoader
                 if showLoader == true {
                     self?.indicatorView.startAnimating()
                 } else if (self?.indicatorView.isAnimating) != nil {
                     self?.indicatorView.stopAnimating()
                 }*/
            }
            .store(in: &cancellables)
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                //  self?.errorLabel.text = errorMessage
                //
                if errorMessage != nil {
                    DispatchQueue.main.async {
                        // TODO: self?.lblNoUpdates.text = errorMessage

                        self?.showRequiredViews()
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.didLoadNextPage()
    }

    private func showRequiredViews() {
        /*
         tblView.isHidden = viewModel.inboxItems.isEmpty
         lblNoUpdates.isHidden = !tblView.isHidden
         lblNoUpdates.isHidden = true
         tblView.isHidden = true*/
    }

    private func setupTopCategories() {
        topCategories.append(CastledViewPagerTabItem(title: "All"))
        let realm = viewModel.realm
        let uniqueCategories = Set(realm.objects(CAppInbox.self)
            .filter("tag != ''")
            .distinct(by: ["tag"])
            .compactMap { $0.tag }).sorted()

        for tag in uniqueCategories {
            topCategories.append(CastledViewPagerTabItem(title: tag))
        }
        for (index, item) in topCategories.enumerated() {
            let castledInboxVC = UIStoryboard(name: "CastledInbox", bundle: Bundle.resourceBundle(for: Castled.self)).instantiateViewController(identifier: "CastledInboxListingViewController") as! CastledInboxListingViewController
            castledInboxVC.currentCategory = item.title
            castledInboxVC.currentIndex = index
            castledInboxVC.inboxViewController = self
            listingViewControllers.append(castledInboxVC)
        }

        let options = CastledViewPagerDisplayConfigs()
        options.hideTabBar = topCategories.count == 1 ? true : false
        // TODO: add other configs

        viewPager = CastledViewPager(viewController: self)
        viewPager?.setDisplayConfigs(config: options)
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
        print("Memory Deallocation")
        removeObservers()
    }

    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if UIDevice.current.orientation.isLandscape {
            print("Landscape \(viewPager?.getCurrentPageIndex() ?? 0)")
        } else {
            print("Portrait \(viewPager?.getCurrentPageIndex() ?? 0)")
        }
        viewPager?.invalidateCurrentTabs()
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

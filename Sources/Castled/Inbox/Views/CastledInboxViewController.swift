//
//  CastledInboxViewController.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import Combine
import RealmSwift
import UIKit

@objc public class OldCastledInboxViewController: UIViewController {
    @IBOutlet weak var lblTitle: UILabel!
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

    private func setupViews() {}

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

    private func getCategories(realm: Realm?) -> [String] {
        let uniqueCategories = Set(realm?.objects(CAppInbox.self)
            .filter("tag != '' && isDeleted == false")
            .distinct(by: ["tag"])
            .compactMap { $0.tag } ?? []).sorted()
        return uniqueCategories
    }

    private func setupTopCategories() {}

    private func createTabViews(tabDisplayConfig: CastledViewPagerDisplayConfigs) {}

    func updateViewPagerAfterDBChanges() {}

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

extension OldCastledInboxViewController: CastledViewPagerDataSource {
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

extension OldCastledInboxViewController: CastledViewPagerDelegate {
    func didMoveToControllerAtIndex(index: Int) {}
}

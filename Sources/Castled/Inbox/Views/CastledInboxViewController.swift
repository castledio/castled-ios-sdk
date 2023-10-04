//
//  CastledInboxViewController.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import Combine
import RealmSwift
import UIKit

@objc public protocol CastledInboxDelegate {
    @objc optional func didSelectedInboxWith(_ action: CastledClickActionType, _ kvPairs: [AnyHashable: Any]?, _ inboxItem: CastledInboxItem)
}

@objc public class CastledInboxViewController: UIViewController {
    @objc public var delegate: CastledInboxDelegate?
    @IBOutlet weak var lblTitle: UILabel!
    var inboxConfig: CastledInboxConfig?
    @IBOutlet private weak var tblView: UITableView!
    @IBOutlet weak var lblNoUpdates: UILabel!
    @IBOutlet weak var viewTopBar: UIView!
    @IBOutlet weak var constraintTopBarHeight: NSLayoutConstraint!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var btnClose: UIButton!
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel = CastledInboxViewModel()
    private var readItems = [CAppInbox]()
    private var notificationToken: NotificationToken?

    override public func viewDidLoad() {
        super.viewDidLoad()
        if Castled.sharedInstance == nil {
            fatalError(CastledExceptionMessages.notInitialised.rawValue)
        }
        setupTableView()
        setupViews()
        bindViewModel()

        // Do any additional setup after loading the view.
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateReadStatus()
    }

    private func setupViews() {
        view.backgroundColor = inboxConfig!.backgroundColor
        indicatorView.color = inboxConfig!.loaderTintColor
        if navigationController?.isNavigationBarHidden == false {
            navigationItem.title = inboxConfig!.title
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
            lblTitle.text = inboxConfig!.title
            btnClose.tintColor = inboxConfig!.navigationBarButtonTintColor
            lblTitle.textColor = inboxConfig!.navigationBarButtonTintColor
            btnClose.isHidden = inboxConfig!.hideCloseButton
        }
        lblNoUpdates.text = inboxConfig!.emptyMessageViewText
        showRequiredViews()
    }

    private func setupTableView() {
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 600
        tblView.register(UINib(nibName: CastledInboxCell.castledInboxImageAndTitleCell, bundle: Bundle.resourceBundle(for: Self.self)), forCellReuseIdentifier: CastledInboxCell.castledInboxImageAndTitleCell)
    }

    private func bindViewModel() {
        notificationToken = viewModel.inboxItems.observe { [weak self] changes in

            switch changes {
                case .initial:
                    // Initial data is loaded
                    self?.tblView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    // Data has been updated, handle deletions, insertions, and modifications
                    self?.tblView.beginUpdates()
                    self?.tblView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self?.tblView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self?.tblView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                    self?.tblView.endUpdates()
                case .error(let error):
                    // Handle error
                    castledLog("Error: \(error)")
            }

            DispatchQueue.main.async {
                self?.showRequiredViews()
            }
        }
        viewModel.$showLoader
            .receive(on: DispatchQueue.main)
            .sink { [weak self] showLoader in
                self?.indicatorView.isHidden = !showLoader
                if showLoader == true {
                    self?.indicatorView.startAnimating()
                } else if (self?.indicatorView.isAnimating) != nil {
                    self?.indicatorView.stopAnimating()
                }
            }
            .store(in: &cancellables)
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                //  self?.errorLabel.text = errorMessage
                //
                if errorMessage != nil {
                    DispatchQueue.main.async {
                        self?.lblNoUpdates.text = errorMessage
                        self?.showRequiredViews()
                    }
                }
            }
            .store(in: &cancellables)

        viewModel.didLoadNextPage()
    }

    private func showRequiredViews() {
        tblView.isHidden = viewModel.inboxItems.isEmpty
        lblNoUpdates.isHidden = !tblView.isHidden
    }

    private func updateReadStatus() {
        Castled.sharedInstance?.logInboxObjectsRead(readItemsObjects: readItems)
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        Castled.sharedInstance?.dismissInboxViewController()
    }

    func removeObservers() {
        cancellables.forEach { $0.cancel() } // Cancel all subscriptions
        notificationToken?.invalidate()
    }

    deinit {
        // This is called when the view controller is deallocated
        removeObservers()
    }
}

extension CastledInboxViewController: UITableViewDelegate, UITableViewDataSource, CastledInboxCellDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.inboxItems.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < viewModel.inboxItems.count && viewModel.inboxItems[indexPath.row].inboxType == .other {
            return 0
        }
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CastledInboxCell
        cell = tableView.dequeueReusableCell(withIdentifier: CastledInboxCell.castledInboxImageAndTitleCell, for: indexPath) as! CastledInboxCell
        cell.configureCellWith(viewModel.inboxItems[indexPath.row])
        cell.delegate = self
        return cell
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = viewModel.inboxItems[indexPath.row]
        if !item.isRead, !readItems.contains(item) {
            readItems.append(item)
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.inboxItems[indexPath.row].messageDictionary
        if let defaultClickAction = item["defaultClickAction"] as? String {
            didSelectedInboxWith(["clickAction": defaultClickAction,
                                  "url": (item["url"] as? String) ?? "",
                                  "keyVals": item["keyVals"] ?? [String: Any]()], CastledInboxResponseConverter.convertToInboxItem(appInbox: viewModel.inboxItems[indexPath.row]))
        }
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {}
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "", handler: { _, _, _ in
            let item = self.viewModel.inboxItems[indexPath.row]
            self.viewModel.showLoader = true
            try? self.viewModel.realm.write {
                item.isDeleted = true
            }

            Castled.sharedInstance?.deleteInboxItem(CastledInboxResponseConverter.convertToInboxItem(appInbox: item), completion: { [weak self] success, _ in
                DispatchQueue.main.async {
                    if success {
                        try? self?.viewModel.realm.write {
                            self?.viewModel.realm.delete(item)
                        }

                    } else {
                        try? self?.viewModel.realm.write {
                            item.isDeleted = false
                        }
                    }
                    self?.viewModel.showLoader = false
                }

            })

        })
        let trashImage = UIImage(named: "castled_swipe_delete_filled", in: Bundle.resourceBundle(for: CastledInboxViewController.self), compatibleWith: nil)
        // deleteAction.image = trashImage
        deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: 35, height: 35)).image { _ in
            trashImage?.draw(in: CGRect(x: 0, y: 0, width: 35, height: 35))
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    public func didSelectedInboxWith(_ kvPairs: [AnyHashable: Any]?, _ inboxItem: CastledInboxItem) {
        let title = (kvPairs?["label"] as? String) ?? ""
        Castled.sharedInstance?.logInboxItemClicked(inboxItem, buttonTitle: title)
        guard (delegate?.didSelectedInboxWith?(CastledConstants.PushNotification.ClickActionType(stringValue: (kvPairs?["clickAction"] as? String) ?? "").getCastledClickActionType(), kvPairs, inboxItem)) != nil else {
            return
        }
    }
}

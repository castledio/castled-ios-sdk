//
//  CastledInboxListingViewController.swift
//  CategoriesTabPOC
//
//  Created by antony on 10/10/2023.
//

import RealmSwift
import UIKit

class CastledInboxListingViewController: UIViewController {
    var currentIndex = 0
    var inboxConfig: CastledInboxDisplayConfig?
    private let refreshControl = UIRefreshControl()

    @IBOutlet private weak var tblView: UITableView!
    @IBOutlet weak var lblNoUpdates: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    private var notificationToken: NotificationToken?

    weak var inboxViewController: CastledInboxViewController?
    var currentCategory: String?
    private lazy var realm: Realm = {
        inboxViewController?.viewModel.realm
        // CastledDBManager.shared.getRealm()

    }()!

    var inboxItems: Results<CAppInbox>?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        populateInboxItems()
        setUpDisplayConfigs()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addRealmObservers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }

    private func setupTableView() {
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 600
        tblView.register(UINib(nibName: CastledInboxCell.castledInboxImageAndTitleCell, bundle: Bundle.resourceBundle(for: Self.self)), forCellReuseIdentifier: CastledInboxCell.castledInboxImageAndTitleCell)
        tblView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshInboxData(_:)), for: .valueChanged)
    }

    @objc private func refreshInboxData(_ sender: Any) {
        inboxViewController?.viewModel.didLoadNextPage()
    }

    private func setUpDisplayConfigs() {
        tblView.backgroundColor = .clear
        indicatorView.color = inboxConfig!.loaderTintColor
        refreshControl.tintColor = inboxConfig!.loaderTintColor
        view.backgroundColor = inboxConfig!.inboxViewBackgroundColor
        lblNoUpdates.text = inboxConfig!.emptyMessageViewText
    }

    private func populateInboxItems() {
        let predicate = currentIndex == 0 ? "isDeleted == false" : "isDeleted == false && tag == '\(currentCategory ?? "")'"
        inboxItems = realm.objects(CAppInbox.self)
            .filter(predicate)
            .sorted(by: [
                SortDescriptor(keyPath: "isPinned", ascending: false),
                SortDescriptor(keyPath: "addedDate", ascending: false)
            ])
    }

    private func addRealmObservers() {
        notificationToken = inboxItems?.observe { [weak self] changes in
            if self?.currentIndex == self?.inboxViewController?.getCurrentPageIndex() {
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
                        if !deletions.isEmpty || !insertions.isEmpty {
                            self?.inboxViewController?.updateViewPagerAfterDBChanges()
                        }
                    case .error(let error):
                        // Handle error
                        CastledLog.castledLog("Inbox listing Error: \(error)", logLevel: CastledLogLevel.error)
                }

                DispatchQueue.main.async {
                    self?.showRequiredViews()
                }
            }
        }
    }

    func removeObservers() {
        notificationToken?.invalidate()
        notificationToken = nil
    }

    private func showRequiredViews() {
        lblNoUpdates.isHidden = !inboxItems!.isEmpty
        showOrHideLoader(showLoader: inboxViewController?.viewModel.showLoader ?? false)
        setErrorTextWith(title: inboxViewController?.viewModel.errorMessage)
    }

    func showOrHideLoader(showLoader: Bool) {
        if let indicator = indicatorView {
            indicator.isHidden = !showLoader
            if showLoader == true {
                if !indicator.isAnimating {
                    indicator.startAnimating()
                }
            } else if indicator.isAnimating {
                indicator.stopAnimating()
            }
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }

    func setErrorTextWith(title: String?) {
        if let lblError = lblNoUpdates, let titleString = title {
            lblError.text = titleString
        }
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
     }
     */
}

extension CastledInboxListingViewController: UITableViewDelegate, UITableViewDataSource, CastledInboxCellDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inboxItems?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < inboxItems!.count && inboxItems![indexPath.row].inboxType == .other {
            return 0
        }
        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CastledInboxCell
        cell = tableView.dequeueReusableCell(withIdentifier: CastledInboxCell.castledInboxImageAndTitleCell, for: indexPath) as! CastledInboxCell
        cell.configureCellWith(inboxItems![indexPath.row])
        cell.delegate = self
        return cell
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = inboxItems![indexPath.row]
        if !item.isRead, !inboxViewController!.readItems.contains(item.messageId) {
            inboxViewController!.readItems.append(item.messageId)
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = inboxItems![indexPath.row].messageDictionary
        if let defaultClickAction = item["defaultClickAction"] as? String {
            didSelectedInboxWith(["clickAction": defaultClickAction,
                                  "url": (item["url"] as? String) ?? "",
                                  CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals: item[CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals] ?? [String: Any]()], CastledInboxResponseConverter.convertToInboxItem(appInbox: inboxItems![indexPath.row]))
        }
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {}
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "", handler: { _, _, _ in
            let item = self.inboxItems![indexPath.row]
            let message_id = item.messageId
            self.inboxViewController?.readItems.removeAll { $0 == message_id }
            Castled.sharedInstance.deleteInboxItem(CastledInboxResponseConverter.convertToInboxItem(appInbox: item))

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
        Castled.sharedInstance.logInboxItemClicked(inboxItem, buttonTitle: title)
        let actionType = CastledConstants.PushNotification.ClickActionType(stringValue: (kvPairs?["clickAction"] as? String) ?? "").getCastledClickActionType()
        CastledButtonActionHandler.notificationClicked(withNotificationType: .inbox, action: actionType, kvPairs: kvPairs, userInfo: nil)
        inboxViewController!.delegate?.didSelectedInboxWith?(CastledButtonActionUtils.getButtonActionFrom(type: actionType, kvPairs: kvPairs), inboxItem: inboxItem)
        guard (inboxViewController!.delegate?.didSelectedInboxWith?(actionType, kvPairs, inboxItem)) != nil else {
            return
        }
    }
}

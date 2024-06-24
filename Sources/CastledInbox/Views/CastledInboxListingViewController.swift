//
//  CastledInboxListingViewController.swift
//  CategoriesTabPOC
//
//  Created by antony on 10/10/2023.
//

import UIKit
@_spi(CastledInternal) import Castled

class CastledInboxListingViewController: UIViewController {
    var currentIndex = 0
    var inboxConfig: CastledInboxDisplayConfig?
    private let refreshControl = UIRefreshControl()
    private var isInsertedOrDeleted = false
    @IBOutlet private weak var tblView: UITableView!
    @IBOutlet weak var lblNoUpdates: UILabel!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!

    weak var inboxViewController: CastledInboxViewController?
    var currentCategory: String?
    lazy var frcViewModel: CastledFRCViewModel = { CastledFRCViewModel(category: currentCategory ?? "", index: currentIndex) }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        populateInboxItems()
        setUpDisplayConfigs()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
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
        lblNoUpdates.textColor = inboxConfig!.emptyMessageViewTextColor
    }

    private func populateInboxItems() {
        let actions = FRCViewModelActions(controllerWillChangeContent: controllerWillChangeContent, controllerDidChangeContent: controllerDidChangeContent, insertSections: insertSections(indexSet:), deleteSections: deleteSections(indexSet:), insertRowsAtIndexPath: insertRowsAtIndexPath(indexPth:), deletRowsAtIndexPath: deletRowsAtIndexPath(indexPth:), updateRowsAtIndexPath: updateRowsAtIndexPath(indexPath:), moveRowsAtIndexPath: moveRowsAtIndexPath(fromIndexPath:newIndexPath:))
        frcViewModel.initialiseActions(actions: actions)
        frcViewModel.setUpDataSource()
    }

    private func addObservers() {
        DispatchQueue.main.async { [weak self] in
            self?.showRequiredViews()
            if self?.frcViewModel.fetchedResultsController.delegate == nil {
                // to reload after tab switching
                self?.tblView.reloadData()
            }
            self?.frcViewModel.fetchedResultsController.delegate = self?.frcViewModel
        }
    }

    func removeObservers() {
        frcViewModel.removeFRCDelegate()
    }

    private func showRequiredViews() {
        lblNoUpdates.isHidden = !(frcViewModel.fetchedResultsController.fetchedObjects?.isEmpty ?? true)
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
        return frcViewModel.numberOfRowsIn(section: section)
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row >= frcViewModel.numberOfRowsIn(section: indexPath.section) || (frcViewModel.fetchedResultsController.object(at: indexPath)).inboxType == CastledInboxType.other.rawValue {
            return 0
        }

        return UITableView.automaticDimension
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CastledInboxCell
        cell = tableView.dequeueReusableCell(withIdentifier: CastledInboxCell.castledInboxImageAndTitleCell, for: indexPath) as! CastledInboxCell
        configure(cell: cell, for: indexPath)
        cell.delegate = self
        return cell
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = frcViewModel.fetchedResultsController.object(at: indexPath)
        if let inboxViewController = inboxViewController,!item.isRead, !inboxViewController.readItems.contains(item.messageId) {
            inboxViewController.readItems.append(item.messageId)
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = (frcViewModel.fetchedResultsController.object(at: indexPath))
        let messageDictionary = item.messageDictionary
        if let defaultClickAction = messageDictionary["defaultClickAction"] as? String {
            didSelectedInboxWith(["clickAction": defaultClickAction,
                                  "url": (messageDictionary["url"] as? String) ?? "",
                                  CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals: messageDictionary[CastledConstants.PushNotification.CustomProperties.Category.Action.keyVals] ?? [String: Any]()], CastledInboxResponseConverter.convertToInboxItem(appInbox: item))
        }
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {}
    }

    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "", handler: { [weak self] _, _, _ in
            if let item = self?.frcViewModel.fetchedResultsController.object(at: indexPath) {
                let message_id = item.messageId
                self?.inboxViewController?.readItems.removeAll { $0 == message_id }
                CastledInbox.sharedInstance.deleteInboxItem(CastledInboxResponseConverter.convertToInboxItem(appInbox: item))
            }

        })
        let trashImage = UIImage(named: "castled_swipe_delete_filled", in: Bundle.resourceBundle(for: CastledInboxViewController.self), compatibleWith: nil)
        // deleteAction.image = trashImage
        deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: 35, height: 35)).image { _ in
            trashImage?.draw(in: CGRect(x: 0, y: 0, width: 35, height: 35))
        }
        deleteAction.backgroundColor = UIColor.systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    public func didSelectedInboxWith(_ kvPairs: [AnyHashable: Any]?, _ inboxItem: CastledInboxItem) {
        let title = (kvPairs?["label"] as? String) ?? ""
        let actionType = ((kvPairs?["clickAction"] as? String) ?? "").getCastledClickActionType()
        if actionType != .none {
            CastledInbox.sharedInstance.logInboxItemClicked(inboxItem, buttonTitle: title)

            inboxViewController?.updateReadStatus()
            CastledButtonActionHandler.notificationClicked(withNotificationType: .inbox, action: actionType, kvPairs: kvPairs, userInfo: nil)
            inboxViewController?.delegate?.didSelectedInboxWith?(CastledButtonActionUtils.getButtonActionFrom(type: actionType, kvPairs: kvPairs), inboxItem: inboxItem)
        }
    }
}

extension CastledInboxListingViewController {
    func numberOfSections(in _: UITableView) -> Int {
        return frcViewModel.numberOfSections()
    }

    func configure(cell: CastledInboxCell?,
                   for indexPath: IndexPath)
    {
        guard let cellN = cell else {
            return
        }
//        guard indexPath.row < frcViewModel.fetchedResultsController.sections?[indexPath.section].numberOfObjects ?? 0 else {
//            return
//        }

        let item = frcViewModel.fetchedResultsController.object(at: indexPath)
        cellN.configureCellWith(item)
    }

    func controllerWillChangeContent() {
        tblView.beginUpdates()
    }

    func controllerDidChangeContent() {
        tblView.endUpdates()
        DispatchQueue.main.async { [weak self] in

            if self?.currentIndex == self?.inboxViewController?.getCurrentPageIndex() {
                if let insertionOrUDeletion = self?.isInsertedOrDeleted, !insertionOrUDeletion {
                    self?.inboxViewController?.updateViewPagerAfterDBChanges()
                }
            }
            self?.showRequiredViews()
        }
        isInsertedOrDeleted = false
    }

    func insertSections(indexSet: IndexSet) {
        isInsertedOrDeleted = true
        tblView.insertSections(indexSet, with: .automatic)
    }

    func deleteSections(indexSet: IndexSet) {
        isInsertedOrDeleted = true
        tblView.deleteSections(indexSet, with: .automatic)
    }

    func insertRowsAtIndexPath(indexPth: IndexPath) {
        isInsertedOrDeleted = true
        tblView.insertRows(at: [indexPth], with: .automatic)
    }

    func deletRowsAtIndexPath(indexPth: IndexPath) {
        isInsertedOrDeleted = true
        tblView.deleteRows(at: [indexPth], with: .automatic)
    }

    func updateRowsAtIndexPath(indexPath: IndexPath) {
        let cell = tblView.cellForRow(at: indexPath)
        guard let new_cell = cell else {
            return
        }
        configure(cell: new_cell as? CastledInboxCell, for: indexPath)
    }

    func moveRowsAtIndexPath(fromIndexPath: IndexPath, newIndexPath: IndexPath) {
        tblView.insertRows(at: [newIndexPath], with: .automatic)
        tblView.deleteRows(at: [fromIndexPath], with: .automatic)
    }
}

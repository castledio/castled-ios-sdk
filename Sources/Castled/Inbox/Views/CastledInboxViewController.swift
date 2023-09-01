//
//  CastledInboxViewController.swift
//  CastledInboxPOC
//
//  Created by antony on 28/08/2023.
//

import UIKit
import Combine

@objc public protocol CastledInboxDelegate  {
    @objc func didSelectedInboxWith(_ kvPairs: [AnyHashable : Any]?,_ inboxItem: CastledInboxItem)
}

@objc public class CastledInboxViewController: UIViewController {
    @objc public var delegate: CastledInboxDelegate?
    @objc internal var inboxItems = [CastledInboxItem]()
    @IBOutlet weak private var tblView: UITableView!
    @IBOutlet weak var lblNoUpdates: UILabel!
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel = CastledInboxViewModel()
    private var readItems = [CastledInboxItem]()

    public override func viewDidLoad() {
        super.viewDidLoad()
        if Castled.sharedInstance == nil {
            fatalError(CastledExceptionMessages.notInitialised.rawValue)
        }
        setupTableView()
        viewModel.inboxItems.append(contentsOf: inboxItems)
        bindViewModel()
        // Do any additional setup after loading the view.
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateReadStatus()
    }
    private func setupTableView() {
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 600
        tblView.register(UINib(nibName: CastledInboxCell.castledInboxImageAndTitleCell, bundle: Bundle.resourceBundle(for: Self.self)), forCellReuseIdentifier: CastledInboxCell.castledInboxImageAndTitleCell)
    }
    
    private func bindViewModel() {
        viewModel.$inboxItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inboxItems in
                if self?.inboxItems != inboxItems{
                    self?.inboxItems.removeAll()
                    self?.inboxItems.append(contentsOf: inboxItems)
                    self?.tblView.reloadData()
                    self?.showRequiredViews()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                //  self?.errorLabel.text = errorMessage
              //
                if(errorMessage != nil){
                    self?.lblNoUpdates.text = errorMessage
                    self?.showRequiredViews()
                }
                
            }
            .store(in: &cancellables)

        viewModel.didLoadNextPage()
    }
    private func showRequiredViews(){
        self.tblView.isHidden = viewModel.inboxItems.count == 0
        self.lblNoUpdates.isHidden = !self.tblView.isHidden
    }
    private func updateReadStatus(){
        Castled.sharedInstance?.logInboxItemsRead(readItems)
    }
    deinit {
        // This is called when the view controller is deallocated
        cancellables.forEach { $0.cancel() } // Cancel all subscriptions
    }
    
}

extension CastledInboxViewController : UITableViewDelegate, UITableViewDataSource,CastledInboxCellDelegate{

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection \(viewModel.inboxItems.count)")
        return viewModel.inboxItems.count
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.row < viewModel.inboxItems.count && viewModel.inboxItems[indexPath.row].inboxType == .other){
            return 0
        }
        return  UITableView.automaticDimension
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CastledInboxCell
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
        print("\(item.messageId) \(readItems.count)")
        
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectedInboxWith(nil, inboxItems[indexPath.row])

    }
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from your data source (e.g., array)
            // Update the table view
//            tableView.deleteRows(at: [indexPath], with: .fade)
            let item = viewModel.inboxItems[indexPath.row]


            Castled.sharedInstance?.deleteInboxItem(viewModel.inboxItems[indexPath.row], completion: { [weak self] success, errorMessage in
                if(success){
                    DispatchQueue.main.async {
                        self?.viewModel.inboxItems.removeAll { $0.messageId == item.messageId }
                        self?.tblView.reloadData()

                    }
                }
            })

        }
    }


    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "", handler: {[weak self]a,b,c in
            if let item = self?.viewModel.inboxItems[indexPath.row]{
                Castled.sharedInstance?.deleteInboxItem(item, completion: { [weak self] success, errorMessage in
                    if(success){
                        DispatchQueue.main.async {
                            self?.viewModel.inboxItems.removeAll { $0.messageId == item.messageId }
                            self?.tblView.deleteRows(at: [indexPath], with: .fade)
//                            self?.tblView.reloadData()

                        }
                    }
                })

            }

        })
        let trashImage = UIImage(named: "castled_swipe_delete_filled", in: Bundle.resourceBundle(for: CastledInboxViewController.self), compatibleWith: nil)
       // deleteAction.image = trashImage
        deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: 35, height: 35)).image { _ in
            trashImage?.draw(in: CGRect(x: 0, y: 0, width: 35, height: 35))
        }
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    public func didSelectedInboxWith(_ kvPairs: [AnyHashable : Any]?, _ inboxItem: CastledInboxItem) {
        let title = (kvPairs?["label"] as? String) ?? ""
        Castled.sharedInstance?.logInboxItemClicked(inboxItem, buttonTitle: title)
        guard (delegate?.didSelectedInboxWith(kvPairs, inboxItem)) != nil else{
            return
        }
    }
}

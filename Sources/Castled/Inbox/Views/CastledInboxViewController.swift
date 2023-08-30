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
    private var cancellables: Set<AnyCancellable> = []
    private var viewModel = CastledInboxViewModel()
    
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
                }
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                //  self?.errorLabel.text = errorMessage
            }
            .store(in: &cancellables)

        viewModel.didLoadNextPage()
    }
    deinit {
        // This is called when the view controller is deallocated
        cancellables.forEach { $0.cancel() } // Cancel all subscriptions
    }
    
}

extension CastledInboxViewController : UITableViewDelegate, UITableViewDataSource,CastledInboxCellDelegate{

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.inboxItems.count
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
        
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard (delegate?.didSelectedInboxWith(nil, viewModel.inboxItems[indexPath.row])) != nil else{
            return
        }

    }
    public func didSelectedInboxWith(_ kvPairs: [AnyHashable : Any]?, _ inboxItem: CastledInboxItem) {
        guard (delegate?.didSelectedInboxWith(kvPairs, inboxItem)) != nil else{
            return
        }
    }
}
